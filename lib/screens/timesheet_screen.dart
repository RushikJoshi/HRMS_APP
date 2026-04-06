import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';

import '../api/api.dart';
import '../models/api/attendance/attendance_log.dart';
import '../models/api/holiday_response.dart';
import '../models/api/leave/leave_dto.dart';
import '../widgets/attendance_calendar.dart';

const Color _primaryColor = Color(0xFF32DBE6);
const Color _backgroundColor = Colors.white;
const Color _surfaceColor = Color(0xFFF8FBFD);
const Color _textPrimary = Colors.black;
const Color _textSecondary = Color(0xFF6B7280);
const Color _borderColor = Color(0xFFE6EDF3);

class TimesheetScreen extends StatefulWidget {
  const TimesheetScreen({super.key});

  @override
  State<TimesheetScreen> createState() => _TimesheetScreenState();
}

class _TimesheetScreenState extends State<TimesheetScreen> {
  final Api _api = Api();

  DateTime _focusedMonth = DateTime(DateTime.now().year, DateTime.now().month);
  DateTime _selectedDay = DateTime.now();

  List<AttendanceLog> _attendanceRecords = [];
  List<LeaveDto> _leaveRequests = [];
  List<Holiday> _holidays = [];

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final attendanceFuture = _api.getMyAttendance(
        month: _focusedMonth.month,
        year: _focusedMonth.year,
      );
      final leaveFuture = _api.getMyLeaves(page: 1, limit: 100);
      final holidayFuture = _api.getHolidays();

      final attendanceResponse = await attendanceFuture;
      List<LeaveDto> leaveRequests = [];
      List<Holiday> holidays = [];

      try {
        leaveRequests = await leaveFuture;
      } catch (_) {}

      try {
        holidays = await holidayFuture;
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        _attendanceRecords = attendanceResponse.data ?? [];
        _leaveRequests = leaveRequests;
        _holidays = holidays;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Unable to load timesheet data.';
      });
    }
  }

  void _onMonthChanged(DateTime focusedDay) {
    setState(() {
      _focusedMonth = DateTime(focusedDay.year, focusedDay.month);
      _selectedDay = DateTime(focusedDay.year, focusedDay.month, 1);
    });
    _fetchData();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    setState(() {
      _selectedDay = DateTime(selectedDay.year, selectedDay.month, selectedDay.day);
      _focusedMonth = DateTime(focusedDay.year, focusedDay.month);
    });
    _showDayDetails(selectedDay);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: _backgroundColor,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 0,
        leading: _buildAppBarButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        title: Text(
          'Timesheet',
          style: TextStyle(
            color: _textPrimary,
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          _buildAppBarButton(
            icon: Icons.refresh_rounded,
            onTap: _fetchData,
          ),
        ],
      ),
      body: _buildBody(context),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: _primaryColor),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(6.w),
          child: _buildErrorCard(),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(4.w, 2.w, 4.w, 5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCalendarSection(),
          SizedBox(height: 4.w),
          _buildSummaryGrid(),
          SizedBox(height: 4.w),
          _buildAttendancePercentageCard(),
          SizedBox(height: 4.w),
          _buildWeeklyChartCard(),
          SizedBox(height: 4.w),
          _buildDetailedStatsCard(),
        ],
      ),
    );
  }

  Widget _buildCalendarSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Monthly Calendar',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: _textPrimary,
          ),
        ),
        SizedBox(height: 1.w),
        Text(
          'Tap a date to view punch details and status.',
          style: TextStyle(
            fontSize: 10.sp,
            color: _textSecondary,
            height: 1.3,
          ),
        ),
        SizedBox(height: 3.w),
        AttendanceCalendar(
          focusedDay: _focusedMonth,
          selectedDays: [_selectedDay],
          onPageChanged: _onMonthChanged,
          onDaySelected: _onDaySelected,
          presentDays: _presentDays,
          absentDays: _absentDays,
          halfDays: _halfDays,
          leaveDays: _leaveDays,
          holidayDays: _holidayDays,
          weekOffDays: _weekOffDays,
        ),
        SizedBox(height: 3.w),
        _buildMiniLegend(),
      ],
    );
  }

  Widget _buildMiniLegend() {
    return Wrap(
      spacing: 2.5.w,
      runSpacing: 2.w,
      children: [
        _legendChip('Present', const Color(0xFF32DBE6)),
        _legendChip('Absent', const Color(0xFFE53935)),
        _legendChip('Leave', const Color(0xFFF4C542)),
        _legendChip('Half Day', const Color(0xFFFFA726)),
        _legendChip('Holiday', const Color(0xFF7E57C2)),
        _legendChip('Week Off', const Color(0xFF9AA5B1)),
      ],
    );
  }

  Widget _legendChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w, vertical: 1.1.w),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 2.4.w,
            height: 2.4.w,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: 1.5.w),
          Text(
            label,
            style: TextStyle(
              fontSize: 8.8.sp,
              color: _textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryGrid() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 3.w,
      mainAxisSpacing: 3.w,
      childAspectRatio: 1.55,
      children: [
        _summaryCard(
          title: 'Total Working Hours',
          value: _formatHours(_sumWorkingHours(_attendanceRecords)),
          icon: Icons.schedule_rounded,
          accentColor: _primaryColor,
        ),
        _summaryCard(
          title: 'Today Working Hours',
          value: _formatHours(_workingHoursForDate(DateTime.now())),
          icon: Icons.today_rounded,
          accentColor: const Color(0xFF2F80ED),
        ),
        _summaryCard(
          title: 'Total Present Days',
          value: _presentDays.length.toString(),
          icon: Icons.check_circle_outline_rounded,
          accentColor: const Color(0xFF4A90E2),
        ),
        _summaryCard(
          title: 'Total Absent Days',
          value: _absentDays.length.toString(),
          icon: Icons.cancel_outlined,
          accentColor: const Color(0xFFE53935),
        ),
      ],
    );
  }

  Widget _summaryCard({
    required String title,
    required String value,
    required IconData icon,
    required Color accentColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(3.5.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 9.w,
            height: 9.w,
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: accentColor, size: 4.5.w),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: _textPrimary,
                ),
              ),
              SizedBox(height: 0.8.w),
              Text(
                title,
                style: TextStyle(
                  fontSize: 9.6.sp,
                  color: _textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttendancePercentageCard() {
    final workingDays = _presentDays.length + _absentDays.length + _leaveDays.length + _halfDays.length;
    final percentage = workingDays == 0
        ? 0.0
        : ((_presentDays.length + (_halfDays.length * 0.5)) / workingDays)
            .clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Attendance Percentage',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: _textPrimary,
                    ),
                  ),
                  SizedBox(height: 0.8.w),
                  Text(
                    'Monthly attendance overview',
                    style: TextStyle(
                      fontSize: 9.6.sp,
                      color: _textSecondary,
                    ),
                  ),
                ],
              ),
              Text(
                '${(percentage * 100).toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: _primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: 3.w),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 1.2.h,
              backgroundColor: const Color(0xFFEAF1F5),
              valueColor: const AlwaysStoppedAnimation<Color>(_primaryColor),
            ),
          ),
          SizedBox(height: 2.2.w),
          Text(
            '$workingDays tracked working days',
            style: TextStyle(
              fontSize: 9.6.sp,
              color: _textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyChartCard() {
    final weekData = _buildWeeklyHoursData();
    final maxHours = math.max(
      1.0,
      weekData.fold<double>(0.0, (maxValue, item) => math.max(maxValue, item.hours)),
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Working Hours',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 0.8.w),
          Text(
            'Work hours for the week around the selected date.',
            style: TextStyle(fontSize: 9.6.sp, color: _textSecondary),
          ),
          SizedBox(height: 4.w),
          SizedBox(
            height: 22.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: weekData.map((entry) {
                final barHeight = (entry.hours / maxHours) * 12.h;
                final safeHeight = math.max(1.2.h, barHeight);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        entry.hours == 0 ? '--' : _formatHours(entry.hours),
                        style: TextStyle(
                          fontSize: 8.8.sp,
                          color: _textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: 7.w,
                        height: safeHeight,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(999),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFF8DECF2), _primaryColor],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _primaryColor.withOpacity(0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 1.2.h),
                      Text(
                        entry.label,
                        style: TextStyle(
                          fontSize: 9.sp,
                          color: _textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailedStatsCard() {
    final stats = <_StatRowData>[
      _StatRowData('Present Days', _presentDays.length, _primaryColor),
      _StatRowData('Absent Days', _absentDays.length, const Color(0xFFE53935)),
      _StatRowData('Leave Days', _leaveDays.length, const Color(0xFFF4C542)),
      _StatRowData('Half Days', _halfDays.length, const Color(0xFFFFA726)),
      _StatRowData('Holidays', _holidayDays.length, const Color(0xFF7E57C2)),
      _StatRowData('Week Off', _weekOffDays.length, const Color(0xFF9AA5B1)),
      _StatRowData('Late In Count', _lateInCount, const Color(0xFF2F80ED)),
      _StatRowData('Early Out Count', _earlyOutCount, const Color(0xFF8D6E63)),
    ];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: EdgeInsets.all(4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Detailed Monthly Stats',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: _textPrimary,
            ),
          ),
          SizedBox(height: 3.w),
          ...stats.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.1.w),
                  child: Row(
                    children: [
                      Container(
                        width: 2.8.w,
                        height: 2.8.w,
                        decoration: BoxDecoration(
                          color: item.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 3.w),
                      Expanded(
                        child: Text(
                          item.label,
                          style: TextStyle(
                            fontSize: 10.5.sp,
                            color: _textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Text(
                        item.value.toString(),
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: _textSecondary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                if (index != stats.length - 1)
                  Divider(height: 0, color: _borderColor),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 12.w,
            color: const Color(0xFFE53935),
          ),
          SizedBox(height: 3.w),
          Text(
            _errorMessage ?? 'Something went wrong.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11.sp,
              color: _textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 2.w),
          Text(
            'Try again to load the attendance details.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 9.8.sp, color: _textSecondary),
          ),
          SizedBox(height: 4.w),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _fetchData,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: 3.w),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text('Retry'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBarButton({required IconData icon, required VoidCallback onTap}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.5.w),
      child: Material(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Icon(icon, color: _textPrimary, size: 4.5.w),
          ),
        ),
      ),
    );
  }

  void _showDayDetails(DateTime day) {
    final attendance = _attendanceForDay(day);
    final leave = _leaveForDay(day);
    final holiday = _holidayForDay(day);
    final status = _dayStatusLabel(day, attendance: attendance, leave: leave, holiday: holiday);
    final statusColor = _statusColor(status);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return SafeArea(
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.72),
            decoration: const BoxDecoration(
              color: _backgroundColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(5.w, 2.2.h, 5.w, 4.h),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 14.w,
                      height: 0.6.h,
                      decoration: BoxDecoration(
                        color: _borderColor,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DateFormat('EEE, dd MMM yyyy').format(day),
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: _textPrimary,
                              ),
                            ),
                            SizedBox(height: 0.8.h),
                            Text(
                              'Attendance details for the selected date',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: _textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      _statusChip(status, statusColor),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  _detailRow(
                    label: 'Punch In Time',
                    value: _timeLabel(attendance?.inTime),
                    icon: Icons.login_rounded,
                  ),
                  SizedBox(height: 1.8.h),
                  _detailRow(
                    label: 'Punch Out Time',
                    value: _timeLabel(attendance?.outTime),
                    icon: Icons.logout_rounded,
                  ),
                  SizedBox(height: 1.8.h),
                  _detailRow(
                    label: 'Total Working Hours',
                    value: _formatHours(_hoursFromText(attendance?.workingHours)),
                    icon: Icons.timelapse_rounded,
                  ),
                  SizedBox(height: 1.8.h),
                  _detailRow(
                    label: 'Status',
                    value: status,
                    icon: Icons.info_outline_rounded,
                  ),
                  if (leave != null) ...[
                    SizedBox(height: 1.8.h),
                    _detailRow(
                      label: 'Leave Type',
                      value: leave.leaveType ?? 'Leave',
                      icon: Icons.event_busy_rounded,
                    ),
                  ],
                  if (holiday != null) ...[
                    SizedBox(height: 1.8.h),
                    _detailRow(
                      label: 'Holiday Name',
                      value: holiday.name,
                      icon: Icons.celebration_rounded,
                    ),
                  ],
                  if (attendance == null && leave == null && holiday == null) ...[
                    SizedBox(height: 2.h),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: _surfaceColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: _borderColor),
                      ),
                      child: Text(
                        'No punch record available for this day.',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: _textSecondary,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: _surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.w,
            decoration: BoxDecoration(
              color: _primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: _primaryColor, size: 4.6.w),
          ),
          SizedBox(width: 3.2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 9.8.sp,
                    color: _textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 0.7.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 11.4.sp,
                    color: _textPrimary,
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

  Widget _statusChip(String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.6.sp,
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  List<_WeeklyHoursData> _buildWeeklyHoursData() {
    final referenceDate = _selectedDay;
    final weekStart = referenceDate.subtract(Duration(days: referenceDate.weekday - 1));

    return List.generate(7, (index) {
      final day = weekStart.add(Duration(days: index));
      return _WeeklyHoursData(
        label: DateFormat('EEE').format(day),
        hours: _workingHoursForDate(day),
      );
    });
  }

  double _sumWorkingHours(List<AttendanceLog> records) {
    return records.fold<double>(0.0, (sum, record) => sum + _hoursFromText(record.workingHours));
  }

  double _workingHoursForDate(DateTime day) {
    return _attendanceRecords
        .where((record) => _isSameDate(_recordDate(record), day))
        .fold<double>(0.0, (sum, record) => sum + _hoursFromText(record.workingHours));
  }

  double _hoursFromText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 0.0;
    }
    return double.tryParse(value.trim()) ?? 0.0;
  }

  String _formatHours(double hours) {
    if (hours <= 0) {
      return '0.00 hrs';
    }
    return '${hours.toStringAsFixed(2)} hrs';
  }

  AttendanceLog? _attendanceForDay(DateTime day) {
    for (final record in _attendanceRecords) {
      if (_isSameDate(_recordDate(record), day)) {
        return record;
      }
    }
    return null;
  }

  LeaveDto? _leaveForDay(DateTime day) {
    for (final leave in _leaveRequests) {
      if (!_isApprovedLeave(leave)) {
        continue;
      }
      final start = _parseDate(leave.startDate);
      final end = _parseDate(leave.endDate);
      if (start == null || end == null) {
        continue;
      }
      final normalizedDay = _dateOnly(day);
      if (!normalizedDay.isBefore(_dateOnly(start)) && !normalizedDay.isAfter(_dateOnly(end))) {
        return leave;
      }
    }
    return null;
  }

  Holiday? _holidayForDay(DateTime day) {
    for (final holiday in _holidays) {
      if (_isSameDate(holiday.date, day)) {
        return holiday;
      }
    }
    return null;
  }

  String _dayStatusLabel(
    DateTime day, {
    AttendanceLog? attendance,
    LeaveDto? leave,
    Holiday? holiday,
  }) {
    final attendanceStatus = attendance?.status?.toLowerCase().trim() ?? '';

    if (holiday != null) {
      return 'Holiday';
    }
    if (_isWeekend(day)) {
      return 'Week Off';
    }
    if (leave != null || attendanceStatus.contains('leave')) {
      return 'Leave';
    }
    if (attendanceStatus.contains('half')) {
      return 'Half Day';
    }
    if (attendanceStatus.contains('absent')) {
      return 'Absent';
    }
    if (attendanceStatus.contains('late') && attendanceStatus.contains('early')) {
      return 'Late In / Early Out';
    }
    if (attendanceStatus.contains('late')) {
      return 'Late In';
    }
    if (attendanceStatus.contains('early')) {
      return 'Early Out';
    }
    if (attendance != null) {
      return 'Present';
    }
    return 'No Record';
  }

  Color _statusColor(String status) {
    final normalized = status.toLowerCase();
    if (normalized.contains('absent')) return const Color(0xFFE53935);
    if (normalized.contains('leave')) return const Color(0xFFF4C542);
    if (normalized.contains('half')) return const Color(0xFFFFA726);
    if (normalized.contains('holiday')) return const Color(0xFF7E57C2);
    if (normalized.contains('week off')) return const Color(0xFF9AA5B1);
    if (normalized.contains('late')) return const Color(0xFF2F80ED);
    if (normalized.contains('early')) return const Color(0xFF8D6E63);
    if (normalized.contains('present')) return _primaryColor;
    return _textSecondary;
  }

  List<DateTime> get _presentDays {
    return _attendanceRecords
        .where((record) => _isPresentStatus(record.status))
        .map((record) => _recordDate(record))
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet()
        .toList();
  }

  List<DateTime> get _absentDays {
    return _attendanceRecords
        .where((record) => _isAbsentStatus(record.status))
        .map((record) => _recordDate(record))
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet()
        .toList();
  }

  List<DateTime> get _halfDays {
    return _attendanceRecords
        .where((record) => _isHalfStatus(record.status))
        .map((record) => _recordDate(record))
        .whereType<DateTime>()
        .map(_dateOnly)
        .toSet()
        .toList();
  }

  List<DateTime> get _leaveDays {
    final days = <DateTime>{};
    for (final leave in _leaveRequests) {
      if (!_isApprovedLeave(leave)) {
        continue;
      }
      final start = _parseDate(leave.startDate);
      final end = _parseDate(leave.endDate);
      if (start == null || end == null) {
        continue;
      }
      var current = _dateOnly(start);
      final last = _dateOnly(end);
      while (!current.isAfter(last)) {
        if (current.year == _focusedMonth.year && current.month == _focusedMonth.month) {
          days.add(current);
        }
        current = current.add(const Duration(days: 1));
      }
    }
    return days.toList();
  }

  List<DateTime> get _holidayDays {
    return _holidays
        .where((holiday) =>
            holiday.date.year == _focusedMonth.year && holiday.date.month == _focusedMonth.month)
        .map((holiday) => _dateOnly(holiday.date))
        .toSet()
        .toList();
  }

  List<DateTime> get _weekOffDays {
    final days = <DateTime>[];
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    for (var day = 1; day <= daysInMonth; day++) {
      final current = DateTime(_focusedMonth.year, _focusedMonth.month, day);
      if (_isWeekend(current)) {
        days.add(current);
      }
    }
    return days;
  }

  int get _lateInCount {
    return _attendanceRecords.where((record) => _isLateInStatus(record.status)).length;
  }

  int get _earlyOutCount {
    return _attendanceRecords.where((record) => _isEarlyOutStatus(record.status)).length;
  }

  bool _isApprovedLeave(LeaveDto leave) {
    return (leave.status ?? '').toLowerCase() == 'approved';
  }

  bool _isPresentStatus(String? status) {
    final normalized = (status ?? '').toLowerCase();
    return normalized.contains('present') || normalized.contains('late') || normalized.contains('early');
  }

  bool _isAbsentStatus(String? status) {
    return (status ?? '').toLowerCase().contains('absent');
  }

  bool _isHalfStatus(String? status) {
    return (status ?? '').toLowerCase().contains('half');
  }

  bool _isLateInStatus(String? status) {
    return (status ?? '').toLowerCase().contains('late');
  }

  bool _isEarlyOutStatus(String? status) {
    return (status ?? '').toLowerCase().contains('early');
  }

  bool _isWeekend(DateTime date) {
    return date.weekday == DateTime.saturday || date.weekday == DateTime.sunday;
  }

  DateTime? _recordDate(AttendanceLog record) {
    return _parseDate(record.date) ?? _parseDate(record.inTime) ?? _parseDate(record.outTime);
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }

  DateTime? _parseDate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }

    try {
      return DateTime.tryParse(value.trim());
    } catch (_) {
      return null;
    }
  }

  bool _isSameDate(DateTime? first, DateTime second) {
    if (first == null) {
      return false;
    }
    final left = _dateOnly(first);
    final right = _dateOnly(second);
    return left.year == right.year && left.month == right.month && left.day == right.day;
  }

  String _timeLabel(String? value) {
    final parsed = _parseDate(value);
    if (parsed != null) {
      return DateFormat('hh:mm a').format(parsed);
    }
    if (value == null || value.trim().isEmpty) {
      return '--:--';
    }
    return value.trim();
  }
}

class _WeeklyHoursData {
  final String label;
  final double hours;

  _WeeklyHoursData({required this.label, required this.hours});
}

class _StatRowData {
  final String label;
  final int value;
  final Color color;

  _StatRowData(this.label, this.value, this.color);
}
