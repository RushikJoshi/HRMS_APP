import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sizer/sizer.dart';

import '../api/api.dart';
import '../services/face_service.dart';
import '../utils/api_constants.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import 'live_face_camera_screen.dart';

class LocationVerificationScreen extends StatefulWidget {
  final bool isPunchIn;
  const LocationVerificationScreen({
    super.key,
    required this.isPunchIn,
  });

  @override
  State<LocationVerificationScreen> createState() => _LocationVerificationScreenState();
}

class _LocationVerificationScreenState extends State<LocationVerificationScreen> {
  final Api _api = Api();
  
  bool _isLocating = true;
  bool _isLocationVerified = false;
  String _locationStatus = 'Locating...';
  Position? _currentPosition;
  
  bool _isVerifyingFace = false;
  bool _isFaceVerified = false;
  File? _capturedImage;
  String _statusMessage = 'Verifying your location...';

  @override
  void initState() {
    super.initState();
    _verifyLocation();
  }

  Future<void> _verifyLocation() async {
    setState(() {
      _isLocating = true;
      _locationStatus = 'Checking permissions...';
    });

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      setState(() => _locationStatus = 'Getting current location...');
      
      final position = await Geolocator.getCurrentPosition();
      _currentPosition = position;

      setState(() => _locationStatus = 'Validating location with server...');
      
      // Validate with API
      await _api.validateAttendanceLocation(position.latitude, position.longitude, position.accuracy);
      
      if (mounted) {
        setState(() {
          _isLocating = false;
          _isLocationVerified = true;
          _statusMessage = 'Location Acquired. Proceeding to Face Verification.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLocating = false;
          _locationStatus = 'Failed: $e';
          _statusMessage = 'Location Verification Failed';
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied.');
    } 

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getValidLocation() async {
    // Ensure permission
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await Geolocator.requestPermission();
      if (permission != LocationPermission.whileInUse &&
          permission != LocationPermission.always) {
        throw Exception("Location permission not granted");
      }
    }

    // Ensure service enabled
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception("Location service disabled");
    }

    // Get position (BLOCKING)
    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
    
    // Update local state for UI display if needed
    _currentPosition = position; 

    final location = "${position.latitude},${position.longitude}";
    debugPrint("✅ LOCATION READY: $location");

    return location;
  }

  Future<void> _startAttendanceFlow() async {
    setState(() {
      _isVerifyingFace = true;
      _statusMessage = 'Step 1/4: Acquiring GPS...';
    });

    try {
      // 1. BLOCKING LOCATION FETCH
      final locationString = await getValidLocation();

      setState(() => _statusMessage = 'Step 2/4: Scanning Face...');

      // 2. OPEN LIVE FACE CAMERA
      final result = await Navigator.of(context).push<FaceCaptureResult>(
        MaterialPageRoute(
          builder: (_) => const LiveFaceCameraScreen(
            mode: FaceCameraMode.verification,
          ),
          fullscreenDialog: true,
        ),
      );

      if (result == null) {
        throw Exception("Camera cancelled");
      }

      setState(() => _statusMessage = 'Processing Face...');

      final File imageFile = result.imageFile;

      // Keep reference for preview if needed
      _capturedImage = imageFile;

      // 2.a Generate embedding using FaceService (same as registration flow)
      final embedding = await FaceService().getFaceEmbedding(imageFile);

      // STRICT VALIDATION – server expects 128-dim embedding
      if (embedding == null || embedding.isEmpty || embedding.length != 128) {
        debugPrint("❌ Face embedding invalid. Length: ${embedding?.length ?? 0}. Cancelling verifyFace call.");
        setState(() {
          _isVerifyingFace = false;
          _statusMessage =
              'Face not clear. Please keep your face in center, look straight and ensure good lighting, then try again.';
        });
        return;
      }

      // Encode image (optional – some backends also accept image along with embedding)
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 3. FACE VERIFICATION API (which ALSO punches the attendance on the backend)
      setState(() => _statusMessage = 'Step 3/4: Verifying Face & Punching...');
      
      // Pass location string, embedding, base64 image, and the action Type
      await _api.verifyFace(
        locationString,
        embedding: embedding,
        base64Image: base64Image,
        actionType: widget.isPunchIn ? 'IN' : 'OUT',
      );

      setState(() {
        _isFaceVerified = true;
        _statusMessage = 'Attendance Recorded Successfully!';
      });

      // NOTE: We DO NOT call punchAttendance API here anymore because the backend's
      // verifyFaceAttendance endpoint automatically creates the Attendance punch record.

      // 5. SUCCESS
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Checked In/Out Successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context, true); // Return TRUE to start Timer
      }

    } catch (e) {
      debugPrint("❌ FLOW FAILED: $e");

      String uiMessage = 'Failed: ${e.toString().replaceAll("Exception:", "")}';

      // Handle API-specific errors (Dio)
      if (e is DioException) {
        final statusCode = e.response?.statusCode;
        final data = e.response?.data;
        final serverMessage = data is Map<String, dynamic> ? data['message']?.toString() : null;

        if (statusCode == 403) {
          // Face mismatch – guide user to re-register face
          uiMessage = serverMessage ??
              'Face mismatch. કૃપા કરીને ફરીથી Face Registration screen પરથી face register કરો અને પછી ફરી પ્રયાસ કરો.';

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(uiMessage),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } else if (statusCode == 400 && (serverMessage?.toLowerCase().contains('location') ?? false)) {
          uiMessage = serverMessage ?? 'Location data invalid. Please enable GPS and try again.';
        } else if (serverMessage != null && serverMessage.isNotEmpty) {
          uiMessage = serverMessage;
        }
      }

      setState(() {
        _isVerifyingFace = false;
        _statusMessage = uiMessage;
      });

      if (mounted && !(e is DioException && e.response?.statusCode == 403)) {
        // For non-403 errors, show generic red snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $uiMessage'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Verification'),
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: Padding(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            // Status Card
            Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                   Icon(
                     _isFaceVerified ? Icons.check_circle : (_isLocationVerified ? Icons.face : Icons.location_on),
                     size: 40.sp,
                     color: _isFaceVerified ? Colors.green : AppColors.primary,
                   ),
                   SizedBox(height: 2.w),
                   Text(
                     _statusMessage,
                     textAlign: TextAlign.center,
                     style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                   ),
                ],
              ),
            ),
            SizedBox(height: 6.w),
            
            // Location Step
            _buildStepTile(
              title: 'Location Verification',
              subtitle: _isLocating ? _locationStatus : (_isLocationVerified ? 'Verified: Lat:${_currentPosition?.latitude.toStringAsFixed(4)}' : 'Failed'),
              icon: Icons.map,
              isCompleted: _isLocationVerified,
              isLoading: _isLocating,
              onRetry: _isLocationVerified ? null : _verifyLocation,
            ),
            
            SizedBox(height: 4.w),
            
            // Face Step
            if (_isLocationVerified)
              _buildStepTile(
                title: 'Face Verification',
                subtitle: _isFaceVerified ? 'Verified' : 'Pending',
                icon: Icons.camera_alt,
                isCompleted: _isFaceVerified,
                isLoading: _isVerifyingFace,
                onRetry: null, // Button below handles it
              ),
            
            Spacer(),
            
            // Action Button
            if (_isLocationVerified && !_isFaceVerified)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isVerifyingFace ? null : _startAttendanceFlow, // Updated method call
                  icon: const Icon(Icons.camera),
                  label: Text(_isVerifyingFace ? 'Verifying...' : 'Take Photo & Punch'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 4.w),
                    textStyle: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              
             if (!_isLocationVerified && !_isLocating)
               SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _verifyLocation,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry Location'),
                   style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 4.w),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isCompleted,
    required bool isLoading,
    VoidCallback? onRetry,
  }) {
    return Container(
      padding: EdgeInsets.all(4.w),
       decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isCompleted ? Colors.green.withOpacity(0.5) : AppColors.gray10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green.withOpacity(0.1) : (isLoading ? Colors.blue.withOpacity(0.1) : Colors.grey.withOpacity(0.1)),
              shape: BoxShape.circle,
            ),
            child: isLoading 
                ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) 
                : Icon(isCompleted ? Icons.check : icon, color: isCompleted ? Colors.green : Colors.grey),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11.sp)),
                Text(subtitle, style: TextStyle(color: Colors.grey, fontSize: 10.sp)),
              ],
            ),
          ),
          if (onRetry != null)
            IconButton(icon: Icon(Icons.refresh), onPressed: onRetry),
        ],
      ),
    );
  }
}
