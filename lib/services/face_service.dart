import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:math' as import_math;

import 'package:flutter/services.dart';

class FaceService {
  static final FaceService _instance = FaceService._internal();
  static const double localMatchThreshold = 0.70;
  factory FaceService() => _instance;
  FaceService._internal();

  late Interpreter _interpreter;
  late FaceDetector _faceDetector;
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      final options = InterpreterOptions();
      // Load model from assets
      // Verify asset exists first
      try {
        await rootBundle.load('assets/models/mobilefacenet.tflite');
      } catch (e) {
        throw Exception("Asset 'assets/models/mobilefacenet.tflite' not found. Ensure it is in pubspec.yaml and you have run a clean build.");
      }

      _interpreter = await Interpreter.fromAsset('assets/models/mobilefacenet.tflite', options: options);

      final optionsFace = FaceDetectorOptions(
        performanceMode: FaceDetectorMode.accurate,
        minFaceSize: 0.15,
        enableLandmarks: true,
      );
      _faceDetector = FaceDetector(options: optionsFace);

      _isInitialized = true;
      debugPrint("FaceService: Initialized successfully");
    } catch (e) {
      debugPrint("FaceService: Initialization failed: $e");
      rethrow;
    }
  }

  Future<List<double>?> getFaceEmbedding(File imageFile) async {
    // 1. Detect Face (Async - Native Background)
    if (!_isInitialized) await initialize();

    final inputImage = InputImage.fromFile(imageFile);
    final faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      debugPrint("FaceService: No face detected.");
      return null;
    }

    if (faces.length > 1) {
      debugPrint("❌ FaceService: Multiple faces detected. Rejected.");
      return null;
    }

    // Get largest face (technically only 1 now, but safe to keep reduce or just take first)
    final face = faces.first;

    // 2. Validate Face Quality (Pose & Size)
    // MobileFaceNet fails if face is rotated > 15 degrees or too small
    if (!_validateFace(face)) {
       debugPrint("FaceService: Face rejected (Poor Quality: Rotated or Too Small)");
       return null; 
    }

    final rect = face.boundingBox;

    // 3. Offload Processing & Inference to Isolate
    try {
       final modelBytes = await rootBundle.load('assets/models/mobilefacenet.tflite');
       final buffer = modelBytes.buffer.asUint8List();

       final props = InferenceProps(
         imagePath: imageFile.path,
         x: rect.left,
         y: rect.top,
         w: rect.width,
         h: rect.height,
         modelBytes: buffer,
       );

       final embedding = await compute(exectuteInferenceInIsolate, props);
       return embedding;

    } catch (e) {
      debugPrint("FaceService: Isolate Error: $e");
      return null;
    }
  }



  bool _validateFace(Face face) {
    // 1. Check Minimum Size (Requirement: >= 100 px)
    // Relaxed from 160px to 100px because some front cameras output low resolution
    // and MobileFaceNet resizes to 112x112 natively anyway.
    if (face.boundingBox.width.toInt() < 100 || face.boundingBox.height.toInt() < 100) {
      debugPrint("❌ Face too small: ${face.boundingBox.width.toInt()}x${face.boundingBox.height.toInt()} (Req: 100+)");
      return false;
    }

    // 2. Check Head Pose (Requirement: <= 25 degrees)
    // Relaxed from 15 to 25 to allow natural device holding angles
    // Y: Head turn left/right (Yaw)
    // Z: Head tilt (Roll)
    final double rotY = face.headEulerAngleY ?? 0;
    final double rotZ = face.headEulerAngleZ ?? 0;

    if (rotY.abs() > 25 || rotZ.abs() > 25) {
      debugPrint("❌ Face rotated too much. Yaw: ${rotY.toStringAsFixed(1)}, Roll: ${rotZ.toStringAsFixed(1)} (Max 25°)");
      return false;
    }

    return true;
  }

  // Dispose is handled by the isolate for the localized interpreter.
  // We only dispose the main thread detector.
  void dispose() {
    _faceDetector.close();
    // _interpreter.close(); // Not using main thread interpreter anymore
  }

  static double compareEmbeddings(List<double> source, List<double> candidate) {
    if (source.isEmpty || candidate.isEmpty) {
      return -1.0;
    }

    final length = import_math.min(source.length, candidate.length);
    double dotProduct = 0.0;

    for (int index = 0; index < length; index++) {
      dotProduct += source[index] * candidate[index];
    }

    final similarity = dotProduct.clamp(-1.0, 1.0);
    return (similarity as num).toDouble();
  }

  static bool isFaceMatch(
    List<double> source,
    List<double> candidate, {
    double threshold = localMatchThreshold,
  }) {
    return compareEmbeddings(source, candidate) >= threshold;
  }
}

// ----------------------------------------------------------------------
// Isolate Logic (Must be Top-Level or Static)
// ----------------------------------------------------------------------

class InferenceProps {
  final String imagePath;
  final double x, y, w, h;
  final Uint8List modelBytes;

  InferenceProps({
    required this.imagePath,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
    required this.modelBytes,
  });
}

Future<List<double>?> exectuteInferenceInIsolate(InferenceProps props) async {
  Interpreter? interpreter;
  try {
    // 1. Load Interpreter FIRST to get expected Input Size
    final options = InterpreterOptions();
    interpreter = Interpreter.fromBuffer(props.modelBytes, options: options);

    final inputTensor = interpreter.getInputTensor(0);
    final inputShape = inputTensor.shape; // e.g., [1, 112, 112, 3] or [1, 160, 160, 3]
    final inputHeight = inputShape[1];
    final inputWidth = inputShape[2];

    // 2. Image Processing
    final file = File(props.imagePath);
    final bytes = await file.readAsBytes();
    final img.Image? originalImage = img.decodeImage(bytes);

    if (originalImage == null) return null;

    // ----------------------------------------------------------------------
    // MANDATORY PREPROCESSING PIPELINE (Reg & Verify MUST MATCH)
    // ----------------------------------------------------------------------
    
    // 1. Crop coordinates with Padding (20%)
    double paddingX = props.w * 0.2;
    double paddingY = props.h * 0.2;
    
    int x = (props.x - paddingX).toInt().clamp(0, originalImage.width - 1);
    int y = (props.y - paddingY).toInt().clamp(0, originalImage.height - 1);
    int w = (props.w + paddingX * 2).toInt();
    int h = (props.h + paddingY * 2).toInt();

    // Ensure crop stays within bounds
    if (x + w > originalImage.width) w = originalImage.width - x;
    if (y + h > originalImage.height) h = originalImage.height - y;

    if (w <= 0 || h <= 0) return null;

    // 2. Crop & Resize to 112x112 (Model Requirement)
    img.Image croppedFace = img.copyCrop(originalImage, x: x, y: y, width: w, height: h);
    img.Image resizedFace = img.copyResize(croppedFace, width: inputWidth, height: inputHeight); // inputWidth/Height should be 112

    // 3. Normalize (/255.0)
    Float32List inputBuffer = Float32List(1 * inputHeight * inputWidth * 3);
    int bufferIndex = 0;
    for (var i = 0; i < inputHeight; i++) {
        for (var j = 0; j < inputWidth; j++) {
            var pixel = resizedFace.getPixel(j, i);
            // REQUIREMENT: Normalize / 255.0
            inputBuffer[bufferIndex++] = pixel.r / 255.0;
            inputBuffer[bufferIndex++] = pixel.g / 255.0;
            inputBuffer[bufferIndex++] = pixel.b / 255.0;
        }
    }

    // ... rest of tensor logic ...
    List<List<List<List<double>>>> input = List.generate(
      1,
      (i) => List.generate(
          inputHeight,
          (y) => List.generate(
              inputWidth,
              (x) => List.generate(3, (c) => 0.0)
          )
      )
    );

    int index = 0;
    for (int row = 0; row < inputHeight; row++) {
      for (int col = 0; col < inputWidth; col++) {
        input[0][row][col][0] = inputBuffer[index++];
        input[0][row][col][1] = inputBuffer[index++];
        input[0][row][col][2] = inputBuffer[index++];
      }
    }
    
    // ... output processing ...
    final outputTensor = interpreter.getOutputTensor(0);
    final outputShape = outputTensor.shape;
    final batchSize = outputShape[0];
    final embeddingSize = outputShape[1];

    var output = List.generate(batchSize, (_) => List.filled(embeddingSize, 0.0));
    interpreter.run(input, output);

    List<double> rawEmbedding = output[0];
    return _adaptTo128InIsolate(rawEmbedding);

  } catch (e) {
    debugPrint("Isolate Execution Error: $e");
    return null;
  } finally {
    interpreter?.close();
  }
}

// Helper for Isolate
List<double> _adaptTo128InIsolate(List<double> raw) {
    List<double> adapted;
    if (raw.length == 128) {
      adapted = List.from(raw);
    } else if (raw.length > 128) {
      adapted = raw.sublist(0, 128);
    } else {
      adapted = List.from(raw)..addAll(List.filled(128 - raw.length, 0.0));
    }

    // Normalize L2 (Euclidean Norm) - Required for Cosine Verify
    double sumSquares = 0.0;
    for (double val in adapted) sumSquares += val * val;
    double norm = (sumSquares > 0) ? 1.0 / import_math.sqrt(sumSquares) : 0.0;

    final result = adapted.map((e) => e * norm).toList();
    
    // Validation: Ensure exactly 128
    if (result.length != 128) {
       return List.filled(128, 0.0);
    }
    return result;
}


