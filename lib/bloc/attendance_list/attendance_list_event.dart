import 'package:equatable/equatable.dart';

abstract class AttendanceListEvent extends Equatable {
  const AttendanceListEvent();

  @override
  List<Object> get props => [];
}

class AttendanceListMonthChanged extends AttendanceListEvent {
  final DateTime month;

  const AttendanceListMonthChanged(this.month);

  @override
  List<Object> get props => [month];
}
