import 'package:equatable/equatable.dart';

abstract class DelegationEvent extends Equatable {
  const DelegationEvent();

  @override
  List<Object?> get props => [];
}

class DelegationEmployeeSelected extends DelegationEvent {
  final String? employeeId;

  const DelegationEmployeeSelected(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class DelegationFromDateChanged extends DelegationEvent {
  final DateTime? fromDate;

  const DelegationFromDateChanged(this.fromDate);

  @override
  List<Object?> get props => [fromDate];
}

class DelegationToDateChanged extends DelegationEvent {
  final DateTime? toDate;

  const DelegationToDateChanged(this.toDate);

  @override
  List<Object?> get props => [toDate];
}

class DelegationReasonChanged extends DelegationEvent {
  final String reason;

  const DelegationReasonChanged(this.reason);

  @override
  List<Object?> get props => [reason];
}

class DelegationSubmitted extends DelegationEvent {
  const DelegationSubmitted();
}

