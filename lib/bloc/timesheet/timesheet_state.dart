import 'package:equatable/equatable.dart';

class TimesheetState extends Equatable {
  final DateTime selectedMonth;

  const TimesheetState({required this.selectedMonth});

  @override
  List<Object?> get props => [selectedMonth];

  TimesheetState copyWith({DateTime? selectedMonth}) {
    return TimesheetState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}

