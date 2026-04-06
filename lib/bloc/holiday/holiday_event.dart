import 'package:equatable/equatable.dart';

abstract class HolidayEvent extends Equatable {
  const HolidayEvent();

  @override
  List<Object?> get props => [];
}

class HolidayMonthChanged extends HolidayEvent {
  final DateTime month;

  const HolidayMonthChanged(this.month);

  @override
  List<Object?> get props => [month];
}

class HolidayPreviousMonth extends HolidayEvent {
  const HolidayPreviousMonth();
}

class HolidayNextMonth extends HolidayEvent {
  const HolidayNextMonth();
}

class HolidayLoad extends HolidayEvent {
  const HolidayLoad();
}
