import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../models/api/attendance/attendance_log.dart';
import '../widgets/attendance_calendar.dart';
import '../widgets/custom_text.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  DateTime _selectedDate = DateTime.now();
  List<DateTime> _selectedDays = [];
  late AttendanceBloc _attendanceBloc;

  @override
  void initState() {
    super.initState();
    _attendanceBloc = AttendanceBloc();
    _fetchHistory();
  }

  @override
  void dispose() {
    _attendanceBloc.close();
    super.dispose();
  }

  void _fetchHistory() {
    _attendanceBloc.add(
      AttendanceHistoryRequested(
        month: _selectedDate.month,
        year: _selectedDate.year,
      ),
    );
  }

  List<DateTime> _getPresentDays(List<AttendanceLog> records) {
    return records
        .where((r) => r.status?.toLowerCase() == 'present')
        .map((r) => _parseDate(r.inTime ?? r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  List<DateTime> _getAbsentDays(List<AttendanceLog> records) {
    return records
        .where((r) => r.status?.toLowerCase() == 'absent')
        .map((r) => _parseDate(r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  List<DateTime> _getLeaveDays(List<AttendanceLog> records) {
    return records
        .where((r) => r.status?.toLowerCase().contains('leave') ?? false)
        .map((r) => _parseDate(r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  List<DateTime> _getHalfDays(List<AttendanceLog> records) {
    return records
        .where((r) => r.status?.toLowerCase().contains('half') ?? false)
        .map((r) => _parseDate(r.date))
        .where((d) => d != null)
        .cast<DateTime>()
        .toList();
  }

  DateTime? _parseDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return null;
    try {
      return DateTime.tryParse(dateStr);
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AttendanceBloc>.value(
      value: _attendanceBloc,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    return Scaffold(
      backgroundColor:  AppColors.surfacePrimary,
      appBar: AppBar(
        title: const CustomText(
          'Attendance',
          isKey: false,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary2,
        ),
        centerTitle: true,
        backgroundColor:  AppColors.surfacePrimary,
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
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state.isLoadingHistory) {
            return const Center(child: CircularProgressIndicator());
          }

          final records = state.attendanceHistory ?? [];

          return SingleChildScrollView(
            padding: EdgeInsets.all(4.w),
            child: Column(
              children: [
                AttendanceCalendar(
                  focusedDay: _selectedDate,
                  selectedDays: _selectedDays,
                  onPageChanged: (newDate) {
                    setState(() {
                      _selectedDate = newDate;
                    });
                    _fetchHistory();
                  },
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      if (_selectedDays.any((d) => isSameDay(d, selectedDay))) {
                        _selectedDays.removeWhere(
                          (d) => isSameDay(d, selectedDay),
                        );
                      } else {
                        _selectedDays = [selectedDay];
                      }
                    });
                  },
                  presentDays: _getPresentDays(records),
                  absentDays: _getAbsentDays(records),
                  leaveDays: _getLeaveDays(records),
                  halfDays: _getHalfDays(records),
                ),
                SizedBox(height: 4.w),
                if (records.isEmpty)
                  _buildEmptyState()
                else
                  ...records.map(
                    (record) => Padding(
                      padding: EdgeInsets.only(bottom: 4.w),
                      child: _buildAttendanceCard(record),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 50.sp,
            color: Colors.grey.shade400,
          ),
          SizedBox(height: 4.w),
          const CustomText(
            'No attendance records found',
            isKey: false,
            fontSize: 14,
            color: Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(AttendanceLog record) {
    String formattedDate = 'Unknown Date';
    try {
      final dateSource = record.inTime ?? record.date;
      if (dateSource != null && dateSource.isNotEmpty) {
        final parsedDate = DateTime.tryParse(dateSource);
        if (parsedDate != null) {
          formattedDate = DateFormat('EEE MMM dd yyyy').format(parsedDate);
        }
      }
    } catch (_) {}

    String checkIn = '--:--';
    if (record.inTime != null && record.inTime!.isNotEmpty) {
      try {
        final parsedCheckIn = DateTime.tryParse(record.inTime!);
        if (parsedCheckIn != null) {
          checkIn = DateFormat('HH:mm').format(parsedCheckIn);
        }
      } catch (_) {}
    }

    String checkOut = '--:--';
    if (record.outTime != null && record.outTime!.isNotEmpty) {
      try {
        final parsedCheckOut = DateTime.tryParse(record.outTime!);
        if (parsedCheckOut != null) {
          checkOut = DateFormat('HH:mm').format(parsedCheckOut);
        }
      } catch (_) {}
    }

    String workingHrs = '0.00 hrs';
    if (record.workingHours != null && record.workingHours!.isNotEmpty) {
      try {
        final hours = double.tryParse(record.workingHours!);
        if (hours != null) {
          workingHrs = '${hours.toStringAsFixed(2)} hrs';
        }
      } catch (_) {}
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.5.w,
            offset: Offset(0, 1.w),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 1.w,
              decoration: BoxDecoration(
                color: _getStatusColor(record.status),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 5.w),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomText(
                          formattedDate,
                          isKey: false,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color:  AppColors.textPrimary2,
                        ),
                        if (record.status != null)
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 2.w,
                              vertical: 0.5.w,
                            ),
                            decoration: BoxDecoration(
                              color: _getStatusColor(
                                record.status,
                              ).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: CustomText(
                              record.status!,
                              isKey: false,
                              fontSize: 10,
                              color: _getStatusColor(record.status),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 6.w),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: _buildStatColumn(
                            'Check In',
                            checkIn,
                             AppColors.loginPrimaryBlue,
                          ),
                        ),
                        Expanded(
                          child: _buildStatColumn(
                            'Check Out',
                            checkOut,
                             AppColors.greenDark,
                          ),
                        ),
                        Expanded(
                          child: _buildStatColumn(
                            "Working Hrs",
                            workingHrs,
                             AppColors.dashboardOrange,
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

  Widget _buildStatColumn(String label, String value, Color valueColor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomText(
          label,
          isKey: false,
          fontSize: 10,
          color: Colors.grey.shade500,
          fontWeight: FontWeight.w500,
        ),
        SizedBox(height: 1.5.w),
        CustomText(
          value,
          isKey: false,
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: valueColor,
        ),
      ],
    );
  }

  Color _getStatusColor(String? status) {
    if (status == null) return Colors.grey;
    final s = status.toLowerCase();
    if (s.contains('present')) return  AppColors.greenDark;
    if (s.contains('absent')) return Colors.red;
    if (s.contains('half')) return Colors.orange;
    if (s.contains('leave')) return Colors.purple;
    return Colors.blue;
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

