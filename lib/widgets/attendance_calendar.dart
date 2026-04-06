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
  static const Color _presentColor = Color(0xFF32DBE6);
  static const Color _absentColor = Color(0xFFE53935);
  static const Color _leaveColor = Color(0xFFF4C542);
  static const Color _halfDayColor = Color(0xFFFFA726);
  static const Color _holidayColor = Color(0xFF7E57C2);
  static const Color _weekOffColor = Color(0xFF9AA5B1);
  static const Color _accentColor = Color(0xFF32DBE6);

  bool _isDayInList(DateTime day, List<DateTime>? dayList) {
    if (dayList == null) return false;
    return dayList.any((d) => isSameDay(d, day));
  }

  Widget _buildDayCell(BuildContext context, DateTime day) {
    final selected = widget.selectedDays.any((d) => isSameDay(d, day));
    final isToday = isSameDay(day, DateTime.now());

    Widget buildCell({
      Color? color,
      required Color textColor,
      Color borderColor = Colors.transparent,
      bool filled = true,
    }) =>
        Container(
          margin: EdgeInsets.all(1.w),
          decoration: BoxDecoration(
            color: filled ? color : Colors.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: selected ? _accentColor : borderColor,
              width: selected ? 1.6 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(filled ? 0.08 : 0.04),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            '${day.day}',
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
              fontSize: 10.5.sp,
            ),
          ),
        );

    // Priority-based styling
    if (_isDayInList(day, widget.absentDays)) {
      return buildCell(color: _absentColor, textColor: Colors.white);
    }
    if (_isDayInList(day, widget.leaveDays)) {
      return buildCell(color: _leaveColor, textColor: Colors.black87);
    }
    if (_isDayInList(day, widget.halfDays)) {
      return buildCell(color: _halfDayColor, textColor: Colors.white);
    }
    if (_isDayInList(day, widget.holidayDays)) {
      return buildCell(color: _holidayColor, textColor: Colors.white);
    }
    if (_isDayInList(day, widget.presentDays)) {
      return buildCell(color: _presentColor, textColor: Colors.white);
    }
    if (_isDayInList(day, widget.weekOffDays)) {
      return buildCell(color: _weekOffColor, textColor: Colors.white);
    }

    // Weekends
    if (day.weekday == DateTime.saturday || day.weekday == DateTime.sunday) {
      return buildCell(
        color: null,
        textColor: Colors.black87,
        borderColor: Colors.grey.shade300,
        filled: false,
      );
    }

    if (isToday) {
      return buildCell(
        color: const Color(0xFFEAFBFD),
        textColor: _accentColor,
        borderColor: _accentColor.withOpacity(0.6),
        filled: true,
      );
    }

    return Container(
      margin: EdgeInsets.all(1.w),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: selected ? _accentColor : Colors.grey.shade300,
          width: selected ? 1.6 : 1,
        ),
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
        _buildLegendItem('Present', _presentColor),
        _buildLegendItem('Absent', _absentColor),
        _buildLegendItem('Leave', _leaveColor),
        _buildLegendItem('Half Day', _halfDayColor),
        _buildLegendItem('Holiday', _holidayColor),
        _buildLegendItem('Week Off', _weekOffColor),
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
