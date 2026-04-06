import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_event.dart';
import '../bloc/holiday/holiday_state.dart';
import '../utils/app_icons.dart';
import '../models/api/holiday_response.dart';

class HolidayCalendarScreen extends StatelessWidget {
  const HolidayCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HolidayBloc(),
      child: const _HolidayCalendarScreenContent(),
    );
  }
}

class _HolidayCalendarScreenContent extends StatelessWidget {
  const _HolidayCalendarScreenContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('Holiday Calendar'),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
      ),
      body: BlocBuilder<HolidayBloc, HolidayState>(
        builder: (context, state) {
          final bloc = context.read<HolidayBloc>();

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: EdgeInsets.all(4.w),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(AppIcons.chevronLeft),
                            onPressed: () {
                              bloc.add(const HolidayPreviousMonth());
                            },
                          ),
                          Text(
                            DateFormat('MMMM yyyy').format(state.focusedDay),
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(AppIcons.chevronRight),
                            onPressed: () {
                              bloc.add(const HolidayNextMonth());
                            },
                          ),
                        ],
                      ),
                      // Calendar view removed per request — only month selector retained.
                    ],
                  ),
                ),
                SizedBox(height: 6.w),
                if (state.loading) ...[
                  Center(child: CircularProgressIndicator()),
                ] else if (state.error != null) ...[
                  Text(
                    'Failed to load holidays',
                    style: TextStyle(color: Colors.red),
                  ),
                ] else if (state.holidays.isEmpty) ...[
                  Text(
                    'No holidays found',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                ] else
                  ...state.holidays.map((h) {
                    final formatted = DateFormat('d MMM yyyy').format(h.date);
                    return Column(
                      children: [
                        _buildHolidayCard(
                          h.name,
                          formatted,
                          h.category ?? 'Holiday',
                        ),
                        SizedBox(height: 3.w),
                      ],
                    );
                  }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHolidayCard(String title, String date, String category) {
    return Container(
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.gray10),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.w),
            decoration: BoxDecoration(
              color: AppColors.secondary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(AppIcons.event, color: AppColors.secondary),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  date,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 9.sp,
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
