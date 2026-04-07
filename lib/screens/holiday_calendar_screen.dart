import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_event.dart';
import '../bloc/holiday/holiday_state.dart';
import '../models/api/holiday_response.dart';
import '../utils/app_colors.dart';

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

class _HolidayCalendarScreenContent extends StatefulWidget {
  const _HolidayCalendarScreenContent();

  @override
  State<_HolidayCalendarScreenContent> createState() =>
      _HolidayCalendarScreenContentState();
}

class _HolidayCalendarScreenContentState
    extends State<_HolidayCalendarScreenContent> {
  List<Holiday> _sortedHolidays(List<Holiday> holidays) {
    final items = holidays.toList();
    items.sort((a, b) => a.date.compareTo(b.date));
    return items;
  }

  Map<String, List<Holiday>> _groupByMonth(List<Holiday> holidays) {
    final grouped = <String, List<Holiday>>{};
    for (final holiday in holidays) {
      final monthKey = DateFormat('MMMM').format(holiday.date);
      grouped.putIfAbsent(monthKey, () => <Holiday>[]).add(holiday);
    }
    return grouped;
  }

  Holiday? _nextUpcomingHoliday(List<Holiday> holidays) {
    if (holidays.isEmpty) return null;

    final today = DateTime.now();
    final todayOnly = DateTime(today.year, today.month, today.day);

    for (final holiday in holidays) {
      final dateOnly = DateTime(
        holiday.date.year,
        holiday.date.month,
        holiday.date.day,
      );
      if (!dateOnly.isBefore(todayOnly)) {
        return holiday;
      }
    }

    return holidays.first;
  }

  String _countdownText(DateTime date) {
    final today = DateTime.now();
    final target = DateTime(date.year, date.month, date.day);
    final diff = target.difference(DateTime(today.year, today.month, today.day)).inDays;

    if (diff == 0) return 'Today is the day';
    if (diff == 1) return 'Only 1 day left';
    if (diff > 1) return 'Only $diff days left';
    return '${diff.abs()} days ago';
  }

  String _holidayTypeLabel(String? category) {
    final value = (category ?? '').trim();
    return value.isEmpty ? 'Holiday' : value;
  }

  String _holidayDescription(Holiday holiday) {
    final category = (holiday.category ?? '').trim().toLowerCase();
    if (category.contains('national')) {
      return 'A national holiday observed across the organization.';
    }
    if (category.contains('festival')) {
      return 'A festival holiday for the selected month.';
    }
    if (category.contains('optional')) {
      return 'An optional holiday that employees may choose to observe.';
    }
    if (category.contains('company')) {
      return 'A company-designated holiday for all employees.';
    }
    return 'A scheduled holiday in the HRMS calendar.';
  }

  Color _categoryColor(String? category) {
    final value = (category ?? '').trim().toLowerCase();
    if (value.contains('national')) return AppColors.dashboardBlue;
    if (value.contains('festival')) return AppColors.dashboardPink;
    if (value.contains('optional')) return AppColors.dashboardOrange;
    if (value.contains('company')) return AppColors.dashboardTeal;
    return AppColors.dashboardBlue;
  }

  String _categoryDisplay(String? category) {
    final value = (category ?? '').trim();
    return value.isEmpty ? 'Holiday' : value;
  }

  void _showHolidayDetails(BuildContext context, Holiday holiday) {
    final accent = _categoryColor(holiday.category);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return SafeArea(
          child: Container(
            padding: EdgeInsets.fromLTRB(5.w, 2.2.h, 5.w, 4.h),
            decoration: const BoxDecoration(
              color: AppColors.bgWhite,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 14.w,
                    height: 0.5.h,
                    decoration: BoxDecoration(
                      color: AppColors.textGrey200,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                SizedBox(height: 2.4.h),
                Row(
                  children: [
                    Container(
                      width: 12.w,
                      height: 12.w,
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(Icons.celebration_rounded, color: accent, size: 5.w),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            holiday.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            DateFormat('EEE, dd MMM yyyy').format(holiday.date),
                            style: TextStyle(
                              fontSize: 10.2.sp,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 2.4.h),
                _detailTile('Type', _categoryDisplay(holiday.category), accent),
                SizedBox(height: 1.4.h),
                _detailTile(
                  'Description',
                  _holidayDescription(holiday),
                  AppColors.dashboardBlue,
                ),
                SizedBox(height: 1.4.h),
                _detailTile(
                  'Status',
                  (holiday.category ?? '').toLowerCase().contains('optional')
                      ? 'Optional holiday'
                      : 'Company holiday',
                  AppColors.dashboardTeal,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _detailTile(String label, String value, Color accentColor) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textGrey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 2.5.w,
            height: 2.5.w,
            margin: EdgeInsets.only(top: 0.6.h),
            decoration: BoxDecoration(
              color: accentColor,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: AppColors.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.5.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.2.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: AppBar(
        backgroundColor: AppColors.bgWhite,
        elevation: 0,
        surfaceTintColor: AppColors.bgWhite,
        leading: const BackButton(color: AppColors.textPrimary),
        title: const Text(
          'Holidays',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: BlocBuilder<HolidayBloc, HolidayState>(
          builder: (context, state) {
            if (state.loading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            }

            if (state.error != null) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.all(6.w),
                  child: Text(
                    'Failed to load holidays',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            }

            final holidays = _sortedHolidays(state.holidays);
            final heroHoliday = _nextUpcomingHoliday(holidays);
            final grouped = _groupByMonth(holidays);
            final monthKeys = grouped.keys.toList();

            return RefreshIndicator(
              onRefresh: () async {
                context.read<HolidayBloc>().add(const HolidayLoad());
              },
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (heroHoliday != null) ...[
                      _buildHeroCard(heroHoliday),
                      SizedBox(height: 2.2.h),
                    ],
                    if (holidays.isEmpty)
                      _buildEmptyState()
                    else
                      ...monthKeys.map((monthKey) {
                        final monthItems = grouped[monthKey] ?? [];
                        return Padding(
                          padding: EdgeInsets.only(bottom: 2.2.h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: EdgeInsets.only(left: 1.w, bottom: 1.2.h),
                                child: Text(
                                  monthKey,
                                  style: TextStyle(
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                              ...monthItems.map(
                                (holiday) => Padding(
                                  padding: EdgeInsets.only(bottom: 1.2.h),
                                  child: _buildHolidayCard(context, holiday),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeroCard(Holiday holiday) {
    final accent = _categoryColor(holiday.category);
    return AppShadowContainer(
      innerBottom: true,
      innerLeft: true,
      innerRight: true,borderRadius: 16,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.w),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.borderColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              top: -8,
              child: Container(
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.12),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.7.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        'Upcoming Holiday',
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.celebration_rounded, color: Colors.yellow, size: 8.w),
                  ],
                ),
                SizedBox(height: 1.8.h),
                Text(
                  holiday.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  DateFormat('EEE, dd MMM yyyy').format(holiday.date),
                  style: TextStyle(
                    color: AppColors.white.withOpacity(0.82),
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 0.8.h),
                Text(
                  _countdownText(holiday.date),
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 1.8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 3.2.w, vertical: 0.8.h),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      _holidayTypeLabel(holiday.category),
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHolidayCard(BuildContext context, Holiday holiday) {
    final accent = _categoryColor(holiday.category);
    final dayText = DateFormat('dd').format(holiday.date);
    final monthText = DateFormat('MMM').format(holiday.date).toUpperCase();
    final weekdayText = DateFormat('EEEE').format(holiday.date);
    final typeLabel = _holidayTypeLabel(holiday.category);

    return GestureDetector(
      onTap: () => _showHolidayDetails(context, holiday),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(3.8.w),
        decoration: BoxDecoration(
          color: AppColors.bgWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.textGrey200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.035),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppShadowContainer(
              innerBottom: true,
              innerRight: true,
              innerLeft: true,
              borderRadius: 13,
              child: Container(
                width: 14.w,
                height: 8.8.h,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
                    Container(
                      height: 2.4.h,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.16),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(14),
                          topRight: Radius.circular(14),
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        monthText,
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 8.4.sp,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: Text(
                          dayText,
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: 17.sp,
                            fontWeight: FontWeight.w800,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(width: 3.2.w),
            Container(
              width: 0.8.w,
              height: 8.6.h,
              decoration: BoxDecoration(
                color: accent.withOpacity(0.95),
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            SizedBox(width: 3.2.w),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(top: 0.2.h),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            holiday.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 12.8.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.1,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.w),
                        Container(
                          width: 2.2.w,
                          height: 2.2.w,
                          margin: EdgeInsets.only(top: 0.4.h),
                          decoration: BoxDecoration(
                            color: accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),
                    Text(
                      weekdayText,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10.2.sp,
                        fontWeight: FontWeight.w600,
                        height: 1.1,
                      ),
                    ),
                    SizedBox(height: 0.8.h),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(horizontal: 2.8.w, vertical: 0.5.h),
                          decoration: BoxDecoration(
                            color: accent.withOpacity(0.10),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              color: accent,
                              fontSize: 8.8.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        SizedBox(width: 2.4.w),
                        Flexible(
                          child: Text(
                            _holidayDescription(holiday),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 9.2.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 2.h),
      padding: EdgeInsets.all(6.w),
      decoration: BoxDecoration(
        color: AppColors.bgWhite,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.textGrey200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(Icons.event_busy_rounded, size: 13.w, color: AppColors.gray),
          SizedBox(height: 1.8.h),
          Text(
            'No holidays found',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(height: 0.8.h),
          Text(
            'Try refreshing the holiday list.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
