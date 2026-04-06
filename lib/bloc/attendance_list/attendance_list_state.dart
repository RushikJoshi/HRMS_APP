import 'package:equatable/equatable.dart';

class AttendanceListState extends Equatable {
  final DateTime selectedMonth;

  const AttendanceListState({
    required this.selectedMonth,
  });

  @override
  List<Object?> get props => [selectedMonth];

  AttendanceListState copyWith({DateTime? selectedMonth}) {
    return AttendanceListState(
      selectedMonth: selectedMonth ?? this.selectedMonth,
    );
  }
}
