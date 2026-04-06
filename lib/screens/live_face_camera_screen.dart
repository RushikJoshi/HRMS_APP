import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:sizer/sizer.dart';

import '../utils/app_colors.dart';

/// Mode of the live camera screen
enum FaceCameraMode { registration, verification }

class FaceCaptureResult {
  final File imageFile;
  FaceCaptureResult({required this.imageFile});
}

class LiveFaceCameraScreen extends StatefulWidget {
  final FaceCameraMode mode;

  const LiveFaceCameraScreen({
    super.key,
    required this.mode,
  });

  @override
  State<LiveFaceCameraScreen> createState() => _LiveFaceCameraScreenState();
}

class _LiveFaceCameraScreenState extends State<LiveFaceCameraScreen>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
      minFaceSize: 0.20,
      enableClassification: false, 
    ),
  );
  bool _isDetecting = false;
  bool _isCapturing = false;

  // States: 'scanning' (red), 'faceFound' (green), 'success' (green solid), 'failure' (red)
  String _scanningState = 'scanning'; 
  int _successHoldFrames = 0;
  String _hintMessage = "Bring face closer to the frame";

  late AnimationController _scanningAnimController;
  late Animation<double> _topLineAnimation;
  late Animation<double> _bottomLineAnimation;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _scanningAnimController = AnimationController(
       vsync: this,
       duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _topLineAnimation = Tween<double>(begin: 0, end: 100).animate(_scanningAnimController);
    _bottomLineAnimation = Tween<double>(begin: 100, end: 0).animate(_scanningAnimController);

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return;

      CameraDescription frontCam = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        frontCam,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isIOS ? ImageFormatGroup.bgra8888 : ImageFormatGroup.yuv420,
      );

      await _cameraController!.initialize();

      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
      });

      _cameraController!.startImageStream(_processFrame);
    } catch (e) {
      debugPrint('LiveFaceCamera: Init Error: $e');
    }
  }

  Future<void> _processFrame(CameraImage image) async {
    if (_isDetecting || _isCapturing || _scanningState == 'success') return;
    _isDetecting = true;

    try {
      final inputImage = _buildInputImage(image);
      if (inputImage == null) {
        _isDetecting = false;
        return;
      }

      final faces = await _faceDetector.processImage(inputImage);

      if (!mounted) {
        _isDetecting = false;
        return;
      }

      if (faces.isNotEmpty) {
        final face = faces.first;
        final yaw = (face.headEulerAngleY ?? 0).abs();
        final roll = (face.headEulerAngleZ ?? 0).abs();
        final rect = face.boundingBox;

        // Image portrait dimensions
        final imgW = image.width < image.height ? image.width.toDouble() : image.height.toDouble();
        final imgH = image.width > image.height ? image.width.toDouble() : image.height.toDouble();

        // 1. Face is fully inside frame (not "kapatu" / cut off)
        final padding = 10.0;
        final bool isFaceInside = rect.left >= padding && rect.top >= padding && 
                                  rect.right <= (imgW - padding) && rect.bottom <= (imgH - padding);

        // 2. Center alignment (મેં શરત કાઢી નાખી છે, ફ્રેમમાં ચહેરો દેખાશે એટલે તરત પાસ થઈ જશે)
        final bool isCentered = true;

        // 3. Minimum size check (ફક્ત FaceService ની 100px ની લિમિટ જેટલું)
        final bool isClose = rect.width >= 100; 

        // 4. Angles check (25 ડિગ્રી સુધી માથું વાંકું હશે તો પણ ચાલશે)
        bool isStraight = yaw <= 25 && roll <= 25;
        // DEBUG LOGGING - WE NEED TO SEE WHY IT FAILS
        print("DEBUG FRAME: Rect[L:${rect.left.toInt()} T:${rect.top.toInt()} R:${rect.right.toInt()} B:${rect.bottom.toInt()}] | W:$imgW H:$imgH | faceW:${rect.width} | In:$isFaceInside Cen:$isCentered Close:$isClose Str:$isStraight (Y:$yaw R:$roll)");

        if (isFaceInside && isClose && isStraight && isCentered) {
          if (_scanningState != 'faceFound') {
             setState(() { 
                _scanningState = 'faceFound'; 
                _hintMessage = "Perfect! Hold still...";
             });
          }
          _successHoldFrames++;
          if (_successHoldFrames > 5) { // ~ 1 second hold
            setState(() { 
              _scanningState = 'success';
              _hintMessage = "Successfully Captured!"; 
            });
            _captureImage();
          }
        } else {
          if (_scanningState != 'scanning') {
             setState(() { _scanningState = 'scanning'; });
          }
          _successHoldFrames = 0;
          
          if (!isFaceInside) {
            setState(() => _hintMessage = "Make sure full face is visible");
          } else if (!isCentered) {
            setState(() => _hintMessage = "Align face in the center");
          } else if (!isClose) {
            setState(() => _hintMessage = "Bring face closer to the camera");
          } else if (!isStraight) {
             setState(() => _hintMessage = "Look straight at the camera");
          }
        }
      } else {
        if (_scanningState != 'scanning') {
           setState(() { 
             _scanningState = 'scanning'; 
             _hintMessage = "Position your face in the frame";
           });
        }
        _successHoldFrames = 0;
      }
    } catch (e) {
       debugPrint("Face detection error: $e");
    } finally {
      if (mounted) {
        _isDetecting = false;
      }
    }
  }

  InputImage? _buildInputImage(CameraImage image) {
    final camera = _cameraController?.description;
    if (camera == null) return null;

    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;

    if (defaultTargetPlatform == TargetPlatform.iOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else {
      var rotationCompensation = sensorOrientation;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (360 - rotationCompensation) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }

    if (rotation == null) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    // ML Kit Android uses nv21 strictly for YUV bytes
    final format = Platform.isIOS ? InputImageFormat.bgra8888 : InputImageFormat.nv21;

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  Future<void> _captureImage() async {
    if (_isCapturing || _cameraController == null) return;
    _isCapturing = true;

    try {
      if (_cameraController!.value.isStreamingImages) {
        await _cameraController!.stopImageStream();
      }
      
      // Delay to let user see success UI
      await Future.delayed(const Duration(milliseconds: 600));

      final XFile file = await _cameraController!.takePicture();
      final imageFile = File(file.path);

      if (mounted) {
        Navigator.of(context).pop(FaceCaptureResult(imageFile: imageFile));
      }
    } catch (e) {
      debugPrint('LiveFaceCamera: Capture Error: $e');
      setState(() {
         _scanningState = 'failure';
         _hintMessage = "Failed to capture. Please retry.";
         _isCapturing = false;
      });
    }
  }

  void _retry() {
    setState(() {
      _scanningState = 'scanning';
      _successHoldFrames = 0;
      _isCapturing = false;
    });
    _cameraController?.startImageStream(_processFrame);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scanningAnimController.dispose();
    if (_cameraController != null && _cameraController!.value.isStreamingImages) {
      _cameraController?.stopImageStream();
    }
    _cameraController?.dispose();
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(widget.mode == FaceCameraMode.registration
        ? 'Face Registration'
        : 'Face Verification', style: TextStyle(color: Colors.black, fontSize: 13.sp, fontWeight: FontWeight.bold),),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back,
                color: AppColors.textPrimary, size: 16.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 2.h),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final containerHeight = 48.h; 
                    
                    _topLineAnimation = Tween<double>(begin: 10, end: containerHeight - 20)
                        .animate(_scanningAnimController);
                    _bottomLineAnimation = Tween<double>(begin: containerHeight - 20, end: 10)
                        .animate(_scanningAnimController);

                    return CustomFaceDetectionWidget(
                      controller: _cameraController,
                      scanningState: _scanningState,
                      hintMessage: _hintMessage,
                      topLineAlignment: _topLineAnimation,
                      bottomLineAlignment: _bottomLineAnimation,
                      retry: _retry,
                    );
                  }
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomFaceDetectionWidget extends StatelessWidget {
  final CameraController? controller;
  final String scanningState;
  final String hintMessage;
  final Animation<double> topLineAlignment;
  final Animation<double> bottomLineAlignment;
  final VoidCallback? retry;

  const CustomFaceDetectionWidget({
    required this.controller,
    required this.scanningState,
    required this.hintMessage,
    required this.topLineAlignment,
    required this.bottomLineAlignment,
    this.retry,
    super.key,
  });

  Color getBorderColor() {
    if (scanningState == 'success') return Colors.green;
    if (scanningState == 'faceFound') return Colors.green; // Active green scanning
    if (scanningState == 'failure') return Colors.red;
    return Colors.red; // default scanning (no face / bad face) -> red
  }

  Widget buildOverLay(BuildContext context) {
    if (scanningState == 'failure') {
      return GestureDetector(
        onTap: retry,
        child: Align(
          child: Container(
             padding: EdgeInsets.all(4.w),
             decoration: const BoxDecoration(
               color: Colors.black54,
               shape: BoxShape.circle,
             ),
             child: Icon(
                Icons.refresh,
                color: Colors.white,
                size: 35.sp,
             ),
          ),
        ),
      );
    }
    return const SizedBox();
  }

  Widget labelMessage(BuildContext context) {
    Color bgColor = getBorderColor();
    
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(2.w),
      color: bgColor,
      child: Text(
        hintMessage,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 12.sp,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget scanningLines(BuildContext context) {
    if (scanningState == 'scanning' || scanningState == 'faceFound') {
      return AnimatedBuilder(
        animation: topLineAlignment,
        builder: (context, child) => Stack(
          children: [
            Positioned(
              top: topLineAlignment.value,
              left: 0,
              right: 0,
              child: Container(
                height: 0.3.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                color: getBorderColor(),
              ),
            ),
            Positioned(
              top: bottomLineAlignment.value,
              left: 0,
              right: 0,
              child: Container(
                height: 0.3.h,
                margin: EdgeInsets.symmetric(horizontal: 10.w),
                color: getBorderColor(),
              ),
            ),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48.h, 
      width: 80.w,
      decoration: BoxDecoration(
        color: Colors.black12, 
        border: Border.all(
          color: getBorderColor(),
          width: 2.w, // Bold dynamic border
        ),
        borderRadius: BorderRadius.circular(27),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(19), 
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (controller != null && controller!.value.isInitialized)
              ClipRect(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: controller!.value.previewSize?.height ?? 100,
                    height: controller!.value.previewSize?.width ?? 100,
                    child: CameraPreview(controller!),
                  ),
                ),
              )
            else
              const Center(child: CircularProgressIndicator(color: AppColors.primary)),
              
            scanningLines(context),
            buildOverLay(context),
            Align(
              alignment: Alignment.bottomCenter,
              child: labelMessage(context),
            ),
          ],
        ),
      ),
    );
  }
}
