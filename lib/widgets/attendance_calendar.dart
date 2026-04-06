import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';

class AttendanceCalendar extends StatefulWidget {
  final Function(DateTime)? onPageChanged;
  final Function(DateTime, DateTime)? onDaySelected;
  final DateTime focusedDay;
  final List<DateTime> selectedDays;
  final List<DateTime>? presentDays;
  final List<DateTime>? absentDays;
  final List<DateTime>? halfDays;
  final List<DateTime>? leaveDays;
  final List<DateTime>? holidayDays;
  final List<DateTime>? weekOffDays;

  const AttendanceCalendar({
    required this.focusedDay,
    required this.selectedDays,
    super.key,
    this.onPageChanged,
    this.onDaySelected,
    this.presentDays,
    this.absentDays,
    this.halfDays,
    this.leaveDays,
    this.holidayDays,
    this.weekOffDays,
  });

  @override
  State<AttendanceCalendar> createState() => _AttendanceCalendarState();
}

class _AttendanceCalendarState extends State<AttendanceCalendar> {
  bool _isDayInList(DateTime day, List<DateTime>? dayList) {
    if (dayList == null) return false;
    return dayList.any((d) => isSameDay(d, day));
  }

  Widget _buildDayCell(BuildContext context, DateTime day) {
    final now = DateTime.now();
    final isPast = day.isBefore(DateTime(now.year, now.month, now.day));

    Widget buildCell({
      required Color color,
      Color textColor = Colors.white,
    }) =>
        Container(
          margin: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 11.sp,
            ),
          ),
        );

    // Priority-based styling
    if (_isDayInList(day, widget.absentDays)) {
      return buildCell(color: Colors.red.shade400);
    }
    if (_isDayInList(day, widget.leaveDays)) {
      return buildCell(color: Colors.purple.shade400);
    }
    if (_isDayInList(day, widget.halfDays)) {
      return buildCell(color: Colors.orange.shade400);
    }
    if (_isDayInList(day, widget.holidayDays)) {
      return buildCell(color: Colors.cyan.shade400);
    }
    if (_isDayInList(day, widget.presentDays)) {
      return buildCell(color: Colors.green.shade400);
    }
    if (_isDayInList(day, widget.weekOffDays)) {
      return buildCell(color: Colors.grey.shade400);
    }

    // Weekends
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return buildCell(
        color: Colors.grey.shade200,
        textColor: Colors.black87,
      );
    }

    // Past days
    if (isPast) {
      return buildCell(
        color: const Color(0xFFCECECE),
        textColor: Colors.black54,
      );
    }

    // Future days
    return Container(
      margin: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 11.sp,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(3.w),
      child: Column(
        children: [
          // Custom Header
          _buildCustomHeader(),
          SizedBox(height: 2.w),
          // Calendar
          TableCalendar(
            firstDay: DateTime.utc(2020),
            lastDay: DateTime.utc(2035, 12, 31),
            focusedDay: widget.focusedDay,
            onPageChanged: (focusedDay) {
              widget.onPageChanged?.call(focusedDay);
            },
            startingDayOfWeek: StartingDayOfWeek.monday,
            selectedDayPredicate: (day) =>
                widget.selectedDays.any((d) => isSameDay(d, day)),
            onDaySelected: (selectedDay, focusedDay) {
              widget.onDaySelected?.call(selectedDay, focusedDay);
            },
            calendarFormat: CalendarFormat.month,
            availableCalendarFormats: const {CalendarFormat.month: 'Month'},
            daysOfWeekStyle: DaysOfWeekStyle(
              weekdayStyle: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
              weekendStyle: TextStyle(
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 10.sp,
              ),
            ),
            calendarStyle: const CalendarStyle(
              outsideDaysVisible: false,
              selectedDecoration: BoxDecoration(
                color: Color(0xFF1976D2),
                shape: BoxShape.circle,
              ),
            ),
            headerVisible: false,
            calendarBuilders: CalendarBuilders(
              defaultBuilder: (context, day, focusedDay) =>
                  _buildDayCell(context, day),
              selectedBuilder: (context, day, focusedDay) =>
                  _buildDayCell(context, day),
              todayBuilder: (context, day, focusedDay) {
                if (widget.selectedDays.any((d) => isSameDay(d, day))) {
                  return null;
                }
                return _buildDayCell(context, day);
              },
            ),
          ),
          SizedBox(height: 3.w),
          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildCustomHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: Icon(Icons.chevron_left, size: 20.sp),
          onPressed: () {
            final newDate = DateTime(
              widget.focusedDay.year,
              widget.focusedDay.month - 1,
            );
            widget.onPageChanged?.call(newDate);
          },
        ),
        Text(
          DateFormat('MMMM yyyy').format(widget.focusedDay),
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF333333),
          ),
        ),
        IconButton(
          icon: Icon(Icons.chevron_right, size: 20.sp),
          onPressed: () {
            final newDate = DateTime(
              widget.focusedDay.year,
              widget.focusedDay.month + 1,
            );
            widget.onPageChanged?.call(newDate);
          },
        ),
      ],
    );
  }

  Widget _buildLegend() {
    return Wrap(
      spacing: 3.w,
      runSpacing: 2.w,
      alignment: WrapAlignment.center,
      children: [
        _buildLegendItem('Present', Colors.green.shade400),
        _buildLegendItem('Absent', Colors.red.shade400),
        _buildLegendItem('Leave', Colors.purple.shade400),
        _buildLegendItem('Half Day', Colors.orange.shade400),
        _buildLegendItem('Holiday', Colors.cyan.shade400),
        _buildLegendItem('Week Off', Colors.grey.shade400),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 3.w,
          height: 3.w,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        SizedBox(width: 1.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 8.sp,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
