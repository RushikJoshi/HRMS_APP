import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('My Reports'),
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(2.5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildMonthlySummary(),
            SizedBox(height: 6.w),
            _buildChartPlaceholder('Monthly Attendance'),
            SizedBox(height: 6.w),
            _buildChartPlaceholder('Leave Summary'),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthlySummary() {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Monthly Summary',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5.w),
          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'Present Days',
                  '22',
                  AppColors.greenDark,
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSummaryItem('Absent Days', '2', AppColors.error),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: _buildSummaryItem(
                  'Leave Days',
                  '3',
                  AppColors.spanishYellow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 1.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 9.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder(String title) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 5.w),
          Container(
            height: 25.h,
            decoration: BoxDecoration(
              color: AppColors.gray5,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'Chart Placeholder',
                style: TextStyle(fontSize: 11.sp, color: AppColors.textSecondary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
