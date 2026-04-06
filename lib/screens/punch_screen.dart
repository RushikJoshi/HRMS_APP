import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../widgets/custom_text.dart';

class PunchScreen extends StatefulWidget {
  const PunchScreen({super.key});

  @override
  State<PunchScreen> createState() => _PunchScreenState();
}

class _PunchScreenState extends State<PunchScreen> {
  late bool _wasPunchedIn;
  bool _wasPunchedOut = false;

  @override
  void initState() {
    super.initState();
    // Initialize based on current bloc state
    _wasPunchedIn = false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const CustomText(
          'Punch In/Out',
          isKey: false,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF333333),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.black, size: 16.sp),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (!state.isInitialized) return;

          // Initialize _wasPunchedIn on first state received
          if (!_wasPunchedIn && state.isPunchedIn) {
            // Check if this is a new punch in (vs loaded from storage)
            if ((state.punchInTime
                        ?.difference(DateTime.now())
                        .inSeconds
                        .abs() ??
                    0) <
                5) {
              // This is a fresh punch in (within last 5 seconds)
              _showSuccessToast('✓ Punch In Successful');
              _wasPunchedIn = true;
            } else {
              // This was loaded from storage, just update the flag
              _wasPunchedIn = true;
            }
          } else if (_wasPunchedIn && !state.isPunchedIn) {
            // Punch out detected
            _showSuccessToast('✓ Punch Out Successful');
            _wasPunchedIn = false;
            _wasPunchedOut = true;
          }

          // Show error message if present
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context).clearSnackBars();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white, size: 18.sp),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: CustomText(
                        state.errorMessage ?? '',
                        isKey: false,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.red.shade600,
                duration: const Duration(seconds: 3),
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.all(4.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            );
          }
        },
        child: BlocBuilder<AttendanceBloc, AttendanceState>(
          builder: (context, state) {
            if (!state.isInitialized) {
              return const Center(child: CircularProgressIndicator());
            }

            return Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(6.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildTimerCard(state),
                    SizedBox(height: 8.h),
                    _buildPunchButton(context, state),
                    SizedBox(height: 4.h),
                    if (state.isPunchedIn) _buildPunchInInfo(state),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimerCard(AttendanceState state) {
    final hours = (state.totalWorkingSeconds ~/ 3600).toString().padLeft(
      2,
      '0',
    );
    final minutes = ((state.totalWorkingSeconds % 3600) ~/ 60)
        .toString()
        .padLeft(2, '0');
    final seconds = (state.totalWorkingSeconds % 60).toString().padLeft(2, '0');

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 6.w),
      child: Column(
        children: [
          CustomText(
            'Working Hours',
            isKey: false,
            fontSize: 14,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
          SizedBox(height: 3.h),
          Text(
            '$hours:$minutes:$seconds',
            style: TextStyle(
              fontSize: 60.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1976D2),
              letterSpacing: 2,
            ),
          ),
          SizedBox(height: 3.h),
          CustomText(
            state.isPunchedIn ? 'Timer Running' : 'Timer Stopped',
            isKey: false,
            fontSize: 13,
            color: state.isPunchedIn
                ? const Color(0xFF00C853)
                : Colors.grey.shade600,
            fontWeight: FontWeight.w600,
          ),
        ],
      ),
    );
  }

  Widget _buildPunchButton(BuildContext context, AttendanceState state) {
    return GestureDetector(
      onTap: () => _handlePunch(context, state),
      child: Container(
        decoration: BoxDecoration(
          color: state.isPunchedIn
              ? const Color(0xFFD32F2F)
              : const Color(0xFF00C853),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color:
                  (state.isPunchedIn
                          ? const Color(0xFFD32F2F)
                          : const Color(0xFF00C853))
                      .withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: EdgeInsets.symmetric(vertical: 5.h, horizontal: 8.w),
        child: Column(
          children: [
            Icon(
              state.isPunchedIn ? Icons.logout : Icons.login,
              size: 32.sp,
              color: Colors.white,
            ),
            SizedBox(height: 2.h),
            CustomText(
              state.isPunchedIn ? 'Punch Out' : 'Punch In',
              isKey: false,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPunchInInfo(AttendanceState state) {
    final punchTime = state.punchInTime;
    final timeStr = punchTime != null
        ? '${punchTime.hour.toString().padLeft(2, '0')}:${punchTime.minute.toString().padLeft(2, '0')}'
        : '--:--';

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
      ),
      padding: EdgeInsets.all(4.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: const Color(0xFF00C853), size: 18.sp),
          SizedBox(width: 2.w),
          CustomText(
            'Punched in at $timeStr',
            isKey: false,
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ],
      ),
    );
  }

  void _showSuccessToast(String message) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 18.sp),
            SizedBox(width: 3.w),
            Expanded(
              child: CustomText(
                message,
                isKey: false,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFF00C853),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(4.w),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  void _handlePunch(BuildContext context, AttendanceState state) {
    if (state.isPunchedIn) {
      context.read<AttendanceBloc>().add(
        AttendancePunchOutRequested(DateTime.now()),
      );
    } else {
      context.read<AttendanceBloc>().add(
        AttendancePunchInRequested(DateTime.now()),
      );
    }
  }
}
