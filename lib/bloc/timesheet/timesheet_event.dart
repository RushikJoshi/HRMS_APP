import 'package:equatable/equatable.dart';

abstract class TimesheetEvent extends Equatable {
  const TimesheetEvent();

  @override
  List<Object?> get props => [];
}

class TimesheetMonthChanged extends TimesheetEvent {
  final DateTime month;

  const TimesheetMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

