import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Help & Support'),
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(5.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFAQSection(),
            SizedBox(height: 6.w),
            _buildContactSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQSection() {
    final faqs = [
      _FAQ('How to apply for leave?', 'Go to Leave section and click on Apply Leave button. Fill the form and submit.'),
      _FAQ('How to check attendance?', 'Go to Attendance section to view your attendance history.'),
      _FAQ('How to download payslip?', 'Go to Payslip section, select month and click download.'),
      _FAQ('What if I forget to punch in?', 'Contact your HR department to mark your attendance manually.'),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Frequently Asked Questions',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 4.w),
        ...faqs.map((faq) => _buildFAQCard(faq)),
      ],
    );
  }

  Widget _buildFAQCard(_FAQ faq) {
    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: ExpansionTile(
        title: Text(
          faq.question,
          style: TextStyle(
            fontSize: 11.5.sp,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Text(
              faq.answer,
              style: TextStyle(
                fontSize: 11.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(AppIcons.supportAgent, size: 36.sp, color: AppColors.primary),
          SizedBox(height: 4.w),
          Text(
            'Need Help?',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            'Contact HR Department for assistance',
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.w),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Opening contact options...'),
                    backgroundColor: AppColors.greenDark,
                  ),
                );
              },
              icon: const Icon(AppIcons.emailRounded),
              label: Text(
                'Contact HR',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: EdgeInsets.symmetric(vertical: 4.w),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FAQ {
  final String question;
  final String answer;

  _FAQ(this.question, this.answer);
}

