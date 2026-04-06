import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/app_colors.dart';
import '../bloc/payslip/payslip_bloc.dart';
import '../bloc/payslip/payslip_event.dart';
import '../bloc/payslip/payslip_state.dart';
import '../utils/app_icons.dart';

class PayslipScreen extends StatelessWidget {
  const PayslipScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PayslipBloc(),
      child: const _PayslipScreenContent(),
    );
  }
}

class _PayslipScreenContent extends StatelessWidget {
  const _PayslipScreenContent();

  Future<void> _selectMonth(BuildContext context) async {
    final bloc = context.read<PayslipBloc>();
    final currentMonth = bloc.state.selectedMonth;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentMonth,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      bloc.add(PayslipMonthChanged(picked));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Payslip'),
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocBuilder<PayslipBloc, PayslipState>(
        builder: (context, state) {
          return SingleChildScrollView(
            padding: EdgeInsets.all(5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildMonthSelector(context, state),
                SizedBox(height: 6.w),
                if (state.loading) ...[
                  Center(child: CircularProgressIndicator()),
                ] else if (state.error != null) ...[
                  Text(
                    'Failed to load payslips',
                    style: TextStyle(color: Colors.red),
                  ),
                ] else if (state.payslips.isEmpty) ...[
                  Text(
                    'No payslips found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ] else ...[
                  _buildPayslipList(context, state),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context, PayslipState state) {
    return InkWell(
      onTap: () => _selectMonth(context),
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.gray10),
        ),
        child: Row(
          children: [
            Icon(AppIcons.calendarMonth, color: AppColors.primary, size: 16.sp),
            SizedBox(width: 3.w),
            Text(
              DateFormat('MMMM yyyy').format(state.selectedMonth),
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Spacer(),
            Icon(
              AppIcons.arrowDown,
              color: AppColors.textSecondary,
              size: 16.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPayslipList(BuildContext context, PayslipState state) {
    return Column(
      children: [
        Icon(AppIcons.file, color: AppColors.primary),
        ...state.payslips.map((p) {
          return Container(
            margin: EdgeInsets.only(bottom: 3.w),
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gray10),
            ),
            child: Row(
              children: [
                Icon(AppIcons.download, color: AppColors.primary),
                SizedBox(width: 3.w),
                Expanded(
                  child: Text(
                    '${p.month} - ₹${p.grossAmount.toStringAsFixed(0)}',
                  ),
                ),
                IconButton(
                  onPressed: () => _downloadPayslip(context, p),
                  icon: const Icon(AppIcons.downloadRounded),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Future<void> _downloadPayslip(BuildContext context, dynamic p) async {
    final url = p.downloadUrl;
    if (url == null || url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No download URL available'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final uri = Uri.tryParse(url);
    if (uri == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid download URL'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    try {
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open download URL'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }
}
