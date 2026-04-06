import 'package:equatable/equatable.dart';

abstract class AttendanceEvent extends Equatable {
  const AttendanceEvent();

  @override
  List<Object?> get props => [];
}

class AttendancePunchInRequested extends AttendanceEvent {
  final DateTime punchInTime;

  const AttendancePunchInRequested(this.punchInTime);

  @override
  List<Object?> get props => [punchInTime];
}

class AttendancePunchOutRequested extends AttendanceEvent {
  final DateTime punchOutTime;

  const AttendancePunchOutRequested(this.punchOutTime);

  @override
  List<Object?> get props => [punchOutTime];
}

class AttendanceTimerTick extends AttendanceEvent {
  const AttendanceTimerTick();
}

class AttendanceBreakStarted extends AttendanceEvent {
  final String breakType; // 'Lunch' or 'Short'
  final int durationMinutes;

  const AttendanceBreakStarted({
    required this.breakType,
    required this.durationMinutes,
  });

  @override
  List<Object?> get props => [breakType, durationMinutes];
}

class AttendanceBreakEnded extends AttendanceEvent {
  const AttendanceBreakEnded();
}

class AttendanceBreakTimerTick extends AttendanceEvent {
  const AttendanceBreakTimerTick();
}

class AttendanceReset extends AttendanceEvent {
  const AttendanceReset();
}

class AttendanceHistoryRequested extends AttendanceEvent {
  final int? month;
  final int? year;

  const AttendanceHistoryRequested({this.month, this.year});

  @override
  List<Object?> get props => [month, year];
}

class AttendanceSummaryRequested extends AttendanceEvent {
  const AttendanceSummaryRequested();
}

class AttendanceInitRequested extends AttendanceEvent {
  const AttendanceInitRequested();
}
