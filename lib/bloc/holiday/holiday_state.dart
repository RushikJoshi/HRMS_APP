import 'package:equatable/equatable.dart';
import '../../models/api/holiday_response.dart';

class HolidayState extends Equatable {
  final DateTime focusedDay;
  final List<Holiday> holidays;
  final bool loading;
  final String? error;

  const HolidayState({
    required this.focusedDay,
    this.holidays = const [],
    this.loading = false,
    this.error,
  });

  @override
  List<Object?> get props => [focusedDay, holidays, loading, error];

  HolidayState copyWith({
    DateTime? focusedDay,
    List<Holiday>? holidays,
    bool? loading,
    String? error,
  }) {
    return HolidayState(
      focusedDay: focusedDay ?? this.focusedDay,
      holidays: holidays ?? this.holidays,
      loading: loading ?? this.loading,
      error: error ?? this.error,
    );
  }
}
