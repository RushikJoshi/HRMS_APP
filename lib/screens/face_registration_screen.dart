import 'dart:io';
import 'dart:convert';


import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../api/api.dart';
import '../services/face_service.dart';
import '../utils/app_colors.dart';
import 'live_face_camera_screen.dart';

class FaceRegistrationScreen extends StatefulWidget {
  const FaceRegistrationScreen({super.key});

  @override
  State<FaceRegistrationScreen> createState() => _FaceRegistrationScreenState();
}

class _FaceRegistrationScreenState extends State<FaceRegistrationScreen>
    with SingleTickerProviderStateMixin {
  // ── State ─────────────────────────────────────────────────────────────────
  bool _isLoading = false;
  String _statusMessage = 'Checking registration status…';
  String? _faceStatus; // 'Registered' | 'Not Registered' | 'Unknown'
  bool _isRegistering = false;

  // Animation for success icon
  late AnimationController _checkAnimCtrl;
  late Animation<double> _checkAnim;

  @override
  void initState() {
    super.initState();
    _checkAnimCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkAnim = CurvedAnimation(parent: _checkAnimCtrl, curve: Curves.elasticOut);
    _checkStatus();
  }

  @override
  void dispose() {
    _checkAnimCtrl.dispose();
    super.dispose();
  }

  // ── API: Check Status ─────────────────────────────────────────────────────
  Future<void> _checkStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Checking registration status…';
      _faceStatus = null;
    });
    try {
      final api = Api();
      final response = await api.getFaceStatus();
      debugPrint('Face Status: $response');
      final isLocalRegistration =
          response is Map && response['source'] == 'local';

      if (mounted) {
        setState(() {
          if (response is Map &&
              (response['registered'] == true ||
                  response['status'] == 'Registered')) {
            _faceStatus = 'Registered';
            _statusMessage = isLocalRegistration
                ? 'Your face is registered on this device.'
                : 'Your face is already registered.';
            _checkAnimCtrl.forward(from: 0);
          } else {
            _faceStatus = 'Not Registered';
            _statusMessage = 'Face not registered yet. Tap below to register.';
          }
        });
      }
    } catch (e) {
      debugPrint('Face Status Error: $e');
      if (mounted) {
        setState(() {
          _faceStatus = 'Unknown';
          _statusMessage = 'Could not fetch status. Please check connection.';
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Open Live Camera ──────────────────────────────────────────────────────
  Future<void> _openCameraAndRegister() async {
    if (_isRegistering) return;

    // Push live camera and wait for captured image
    final result = await Navigator.of(context).push<FaceCaptureResult>(
      MaterialPageRoute(
        builder: (_) =>
            const LiveFaceCameraScreen(mode: FaceCameraMode.registration),
        fullscreenDialog: true,
      ),
    );

    if (result == null) return; // User cancelled

    await _processCapture(result.imageFile);
  }

  // ── Process + Register ────────────────────────────────────────────────────
  Future<void> _processCapture(File imageFile) async {
    _isRegistering = true;
    setState(() {
      _isLoading = true;
      _statusMessage = 'Processing face… please wait';
    });

    try {
      // 1. Get embedding
      final embedding = await FaceService().getFaceEmbedding(imageFile);

      if (embedding == null || embedding.isEmpty || embedding.length != 128) {
        _showSnack(
          'Face quality too low. Please look straight & ensure good lighting.',
          isError: true,
        );
        setState(() {
          _statusMessage = 'Registration failed – face rejected.';
          _isLoading = false;
        });
        return;
      }

      // 2. Read image as base64
      final bytes = await imageFile.readAsBytes();
      final base64Image = base64Encode(bytes);

      // 3. Register via API
      await Api().registerFace(embedding, employeeName: 'Employee', image: base64Image);


      setState(() {
        _statusMessage = 'Face Registered Successfully! ✅';
        _faceStatus = 'Registered';
      });
      _checkAnimCtrl.forward(from: 0);

      _showSnack('Face registered successfully!', isError: false);
      _checkStatus(); // refresh
    } catch (e) {
      debugPrint('Registration Error: $e');
      setState(() => _statusMessage = 'Registration Failed: $e');
      _showSnack('Registration failed: $e', isError: true);
    } finally {
      _isRegistering = false;
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnack(String msg, {required bool isError}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isError ? AppColors.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Face Registration'),
        backgroundColor: AppColors.bgWhite,
        foregroundColor: AppColors.textPrimary,
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            SizedBox(height: 4.h),
            // ── Status Card ─────────────────────────────────────────────
            _buildStatusCard(),
            SizedBox(height: 4.h),
            // ── Instructions Card ───────────────────────────────────────
            _buildInstructions(),
            SizedBox(height: 4.h),
            // ── Action Button ───────────────────────────────────────────
            if (!_isLoading) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _openCameraAndRegister,
                  icon: const Icon(Icons.face_retouching_natural),
                  label: Text(
                    _faceStatus == 'Registered'
                        ? 'Re-Register Face'
                        : 'Register Face',
                    style: TextStyle(
                        fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 4.w),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              TextButton.icon(
                onPressed: _checkStatus,
                icon: const Icon(Icons.refresh),
                label: const Text('Refresh Status'),
              ),
            ] else
              Column(
                children: [
                  const CircularProgressIndicator(),
                  SizedBox(height: 2.h),
                  Text(
                    _statusMessage,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 10.sp, color: AppColors.textSecondary),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  // ── Status Card ───────────────────────────────────────────────────────────
  Widget _buildStatusCard() {
    final isRegistered = _faceStatus == 'Registered';
    final color = isRegistered ? Colors.green : AppColors.primary;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.12),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: color.withOpacity(0.25), width: 1.5),
      ),
      child: Column(
        children: [
          // Icon area
          Container(
            width: 22.w,
            height: 22.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withOpacity(0.1),
            ),
            child: _isLoading && _faceStatus == null
                ? Padding(
                    padding: EdgeInsets.all(4.w),
                    child:
                        CircularProgressIndicator(strokeWidth: 2.5, color: color),
                  )
                : isRegistered
                    ? ScaleTransition(
                        scale: _checkAnim,
                        child: Icon(Icons.verified_user,
                            size: 28.sp, color: Colors.green),
                      )
                    : Icon(Icons.face, size: 28.sp, color: AppColors.primary),
          ),
          SizedBox(height: 3.w),
          Text(
            isRegistered ? 'Registered' : (_faceStatus ?? 'Unknown'),
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 1.w),
          Text(
            _statusMessage,
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 10.sp, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  // ── Instructions ──────────────────────────────────────────────────────────
  Widget _buildInstructions() {
    const tips = [
      ('Good lighting', 'Make sure your face is well lit', Icons.wb_sunny),
      ('Look straight', 'Face the camera directly', Icons.remove_red_eye),
      ('Stay still', 'Hold still for auto-capture', Icons.do_not_disturb_on),
      ('No glasses', 'Remove glasses if possible', Icons.remove_circle_outline),
    ];

    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gray10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Tips for best results',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11.sp,
                  color: AppColors.textPrimary)),
          SizedBox(height: 3.w),
          ...tips.map((tip) => Padding(
                padding: EdgeInsets.only(bottom: 2.w),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(1.5.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(tip.$3,
                          size: 12.sp, color: AppColors.primary),
                    ),
                    SizedBox(width: 3.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tip.$1,
                            style: TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 10.sp)),
                        Text(tip.$2,
                            style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 9.sp)),
                      ],
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
