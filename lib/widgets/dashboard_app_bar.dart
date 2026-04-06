import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import 'package:intl/intl.dart';
import 'custom_text.dart';

class DashboardAppBar extends StatelessWidget {
  final String? userName;
  final String? designation;
  final String? profilePictureUrl;
  final VoidCallback? onProfileTap;

  const DashboardAppBar({
    super.key,
    this.userName,
    this.designation,
    this.profilePictureUrl,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(4.w, 4.w, 4.w, 3.w),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Picture
          InkWell(
            onTap: onProfileTap,
            child: Container(
              width: 12.w,
              height: 12.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade200,
                border: Border.all(color: AppColors.dashboardBlue.withOpacity(0.2), width: 1),
              ),
              child: ClipOval(
                child: profilePictureUrl != null && profilePictureUrl!.isNotEmpty
                    ? Image.network(profilePictureUrl!, fit: BoxFit.cover)
                    : Center(
                        child: CustomText(
                          userName != null && userName!.isNotEmpty ? userName!.substring(0, 2).toUpperCase() : 'MC',
                          isKey: false,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dashboardBlue,
                        ),
                      ),
              ),
            ),
          ),
          SizedBox(width: 3.5.w),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: CustomText(
                        userName ?? 'User Name',
                        isKey: false,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    SizedBox(width: 1.5.w),
                    Icon(Icons.verified, color: AppColors.dashboardBlue, size: 4.w),
                  ],
                ),
                CustomText(
                  designation ?? 'Role',
                  isKey: false,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.dashboardOrange,
                ),
                SizedBox(height: 0.5.w),
                const LiveClock(),
              ],
            ),
          ),

          // Search and Notification Buttons
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildIconButton(Icons.search, Colors.cyan.shade50, Colors.cyan.shade600),
              SizedBox(width: 2.w),
              _buildIconButton(Icons.notifications_outlined, Colors.cyan.shade50, Colors.cyan.shade600),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIconButton(IconData icon, Color bgColor, Color iconColor) {
    return Container(
      width: 10.w,
      height: 10.w,
      decoration: BoxDecoration(
        color: bgColor,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: iconColor, size: 5.5.w),
    );
  }
}

class LiveClock extends StatefulWidget {
  const LiveClock({super.key});

  @override
  State<LiveClock> createState() => _LiveClockState();
}

class _LiveClockState extends State<LiveClock> {
  late Timer _timer;
  late String _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = _formatDateTime(DateTime.now());
    _timer = Timer.periodic(const Duration(seconds: 1), (Timer t) => _updateTime());
  }

  void _updateTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (mounted) {
      setState(() {
        _currentTime = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat('EEE, dd MMM yyyy • hh:mm:ss a').format(dateTime);
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomText(
      _currentTime,
      isKey: false,
      fontSize: 9,
      fontWeight: FontWeight.w500,
      color: Colors.grey.shade500,
    );
  }
}
