import 'package:equatable/equatable.dart';

class DelegationState extends Equatable {
  final String? selectedEmployee;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String reason;
  final bool isSubmitting;
  final String? errorMessage;

  const DelegationState({
    this.selectedEmployee,
    this.fromDate,
    this.toDate,
    this.reason = '',
    this.isSubmitting = false,
    this.errorMessage,
  });

  @override
  List<Object?> get props => [selectedEmployee, fromDate, toDate, reason, isSubmitting, errorMessage];

  DelegationState copyWith({
    String? selectedEmployee,
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
    bool? isSubmitting,
    String? errorMessage,
  }) {
    return DelegationState(
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

