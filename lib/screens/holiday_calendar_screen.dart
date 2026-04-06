import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import '../bloc/holiday/holiday_bloc.dart';
import '../bloc/holiday/holiday_event.dart';
import '../bloc/holiday/holiday_state.dart';
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

class _HolidayCalendarScreenContent extends StatefulWidget {
  const _HolidayCalendarScreenContent();

  @override
  State<_HolidayCalendarScreenContent> createState() =>
      _HolidayCalendarScreenContentState();
}

class _HolidayCalendarScreenContentState
    extends State<_HolidayCalendarScreenContent> {
  final TextEditingController _searchController = TextEditingController();
  late DateTime _focusedYear;

  @override
  void initState() {
    super.initState();
    _focusedYear = DateTime.now();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Holiday> _filterHolidays(List<Holiday> holidays) {
    final query = _searchController.text.trim().toLowerCase();
    if (query.isEmpty) {
      return holidays;
    }

    return holidays.where((holiday) {
      final title = holiday.name.toLowerCase();
      final category = (holiday.category ?? '').toLowerCase();
      final dateLabel = DateFormat(
        'dd MMM yyyy',
      ).format(holiday.date).toLowerCase();
      return title.contains(query) ||
          category.contains(query) ||
          dateLabel.contains(query);
    }).toList();
  }

  void _openYearPicker(BuildContext context, HolidayBloc bloc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        final currentYear = DateTime.now().year;
        final years = List<int>.generate(7, (index) => currentYear - 3 + index);

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select Year',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: years.map((year) {
                    final selected = year == _focusedYear.year;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _focusedYear = DateTime(year);
                        });
                        bloc.add(HolidayMonthChanged(DateTime(year, 1)));
                        Navigator.pop(context);
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        decoration: BoxDecoration(
                          color: selected ? AppColors.primary : AppColors.gray5,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: selected
                                ? AppColors.primary
                                : AppColors.textBorder300,
                          ),
                        ),
                        child: Text(
                          '$year',
                          style: TextStyle(
                            color: selected
                                ? AppColors.white
                                : AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        leading: const BackButton(color: Colors.black),
        title: const Text(
          'Holidays',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.w500,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Builder(
              builder: (appBarContext) {
                return InkWell(
                  onTap: () => _openYearPicker(
                    appBarContext,
                    appBarContext.read<HolidayBloc>(),
                  ),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(11),
                      border: Border.all(color: AppColors.textBorder300),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'All, ${_focusedYear.year}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 2),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 22,
                          color: AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(2.w, 1.h, 2.w, 0),
              child: Container(
                height: 6.5.h,
                decoration: BoxDecoration(
                  color: AppColors.gray5,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(color: AppColors.textGrey200),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    fontSize: 12.5.sp,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search',
                    hintStyle: TextStyle(
                      fontSize: 12.5.sp,
                      color: AppColors.textGray,
                      fontWeight: FontWeight.w400,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textGray,
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.8.h,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<HolidayBloc, HolidayState>(
                builder: (context, state) {
                  final holidays = _filterHolidays(state.holidays);

                  if (state.loading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state.error != null) {
                    return Center(
                      child: Text(
                        'Failed to load holidays',
                        style: TextStyle(
                          color: AppColors.error,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  }

                  if (holidays.isEmpty) {
                    return Center(
                      child: Text(
                        'No holidays found',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12.sp,
                        ),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: EdgeInsets.only(top: 1.2.h, bottom: 2.h),
                    itemCount: holidays.length,
                    itemBuilder: (context, index) {
                      final holiday = holidays[index];
                      final isPast = holiday.date.isBefore(
                        DateTime.now().subtract(const Duration(days: 1)),
                      );
                      final monthText = DateFormat(
                        'MMM',
                      ).format(holiday.date).toUpperCase();
                      final dayText = DateFormat('dd').format(holiday.date);
                      final weekdayText = DateFormat(
                        'EEEE',
                      ).format(holiday.date);
                      final categoryText = (holiday.category ?? '').trim();

                      return Container(
                        key: ValueKey(holiday.id ?? '${holiday.name}-$index'),
                        padding: EdgeInsets.symmetric(
                          horizontal: 4.w,
                          vertical: 1.7.h,
                        ),
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 10.w,
                              height: 7.5.h,
                              decoration: BoxDecoration(
                                color: isPast
                                    ? const Color(0xFFB0B0B0)
                                    : _colorForIndex(index),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 2.3.h,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.16),
                                      borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(4),
                                        topRight: Radius.circular(4),
                                      ),
                                    ),
                                    child: Text(
                                      monthText,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 8.5.sp,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                                  ),
                                  Expanded(
                                    child: Center(
                                      child: Text(
                                        dayText,
                                        style: TextStyle(
                                          color: Colors.white,
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
                            SizedBox(width: 3.5.w),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(top: 0.2.h),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      holiday.name,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        color: AppColors.textPrimary,
                                        fontSize: 12.5.sp,
                                        fontWeight: FontWeight.w800,
                                        height: 1.1,
                                      ),
                                    ),
                                    SizedBox(height: 0.3.h),
                                    Text(
                                      weekdayText,
                                      style: TextStyle(
                                        color: AppColors.textGray,
                                        fontSize: 10.5.sp,
                                        fontWeight: FontWeight.w500,
                                        height: 1.1,
                                      ),
                                    ),
                                    if (categoryText.isNotEmpty) ...[
                                      SizedBox(height: 0.3.h),
                                      Text(
                                        categoryText,
                                        style: TextStyle(
                                          color: AppColors.textGray,
                                          fontSize: 10.5.sp,
                                          fontWeight: FontWeight.w500,
                                          height: 1.1,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ),
                            if (categoryText.toLowerCase() == 'optional') ...[
                              SizedBox(width: 2.w),
                              _ActionChip(
                                title: index.isEven ? 'Apply' : 'Applied',
                                backgroundColor: index.isEven
                                    ? const Color(0xFF3D73A8)
                                    : const Color(0xFFD7F0DB),
                                textColor: index.isEven
                                    ? Colors.white
                                    : const Color(0xFF2E6C36),
                              ),
                            ],
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _colorForIndex(int index) {
    const colors = <Color>[
      Color(0xFF2F648E),
      Color(0xFF2FBBA4),
      Color(0xFF08A4BB),
      Color(0xFFFFC026),
      Color(0xFFFF8A00),
      Color(0xFF7A5AF8),
      Color(0xFFEF5DA8),
    ];
    return colors[index % colors.length];
  }
}

class _ActionChip extends StatelessWidget {
  final String title;
  final Color backgroundColor;
  final Color textColor;

  const _ActionChip({
    required this.title,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w700,
          height: 1,
        ),
      ),
    );
  }
}
