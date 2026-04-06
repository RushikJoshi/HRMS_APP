import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';

class ShiftDetailsScreen extends StatelessWidget {
  const ShiftDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Shift Details'),
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildShiftCard(),
            SizedBox(height: 5.w),
            _buildBreakInfo(),
            SizedBox(height: 5.w),
            _buildWeeklyOff(),
          ],
        ),
      ),
    );
  }

  Widget _buildShiftCard() {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.littleDarkBlue],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Text(
            'General Shift',
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          SizedBox(height: 2.w),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(AppIcons.clock, color: Colors.white.withOpacity(0.9)),
              SizedBox(width: 2.w),
              Text(
                '10:00 AM - 7:00 PM',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBreakInfo() {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Break Information',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.w),
          _buildInfoRow(
            AppIcons.restaurant,
            'Lunch Break',
            '12:30 PM - 1:30 PM',
          ),
          SizedBox(height: 3.w),
          _buildInfoRow(
            AppIcons.coffeeRounded,
            'Short Break',
            '3:30 PM - 3:45 PM',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        SizedBox(width: 3.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildWeeklyOff() {
    return Container(
      padding: EdgeInsets.all(2.5.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Off',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.w),
          Wrap(
            spacing: 2.w,
            runSpacing: 2.w,
            children: ['Sunday'].map((day) {
              return Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.5.w,
                  vertical: 2.5.w,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}
