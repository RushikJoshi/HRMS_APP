import 'package:equatable/equatable.dart';
import '../../models/leave/leave_request_model.dart';
import '../../models/api/profile_response.dart'; // For ProfileData and LeaveRule
import 'dart:io';

abstract class ApplyLeaveEvent extends Equatable {
  const ApplyLeaveEvent();

  @override
  List<Object?> get props => [];
}

class ApplyLeaveTypeChanged extends ApplyLeaveEvent {
  final LeaveType? leaveType;

  const ApplyLeaveTypeChanged(this.leaveType);

  @override
  List<Object?> get props => [leaveType];
}

// New event for selecting leave type from policy
class ApplyLeaveRuleChanged extends ApplyLeaveEvent {
  final LeaveRule? leaveRule;

  const ApplyLeaveRuleChanged(this.leaveRule);

  @override
  List<Object?> get props => [leaveRule];
}

class ApplyLeaveFromDateChanged extends ApplyLeaveEvent {
  final DateTime? fromDate;

  const ApplyLeaveFromDateChanged(this.fromDate);

  @override
  List<Object?> get props => [fromDate];
}

class ApplyLeaveToDateChanged extends ApplyLeaveEvent {
  final DateTime? toDate;

  const ApplyLeaveToDateChanged(this.toDate);

  @override
  List<Object?> get props => [toDate];
}

class ApplyLeaveReasonChanged extends ApplyLeaveEvent {
  final String reason;

  const ApplyLeaveReasonChanged(this.reason);

  @override
  List<Object?> get props => [reason];
}

class ApplyLeaveToggleOnBehalf extends ApplyLeaveEvent {
  const ApplyLeaveToggleOnBehalf();
}

class ApplyLeaveEmployeeSelected extends ApplyLeaveEvent {
  final String? employeeId;

  const ApplyLeaveEmployeeSelected(this.employeeId);

  @override
  List<Object?> get props => [employeeId];
}

class ApplyLeavePasswordVisibilityToggled extends ApplyLeaveEvent {
  const ApplyLeavePasswordVisibilityToggled();
}

class ApplyLeaveHalfDayToggled extends ApplyLeaveEvent {
  const ApplyLeaveHalfDayToggled();
}

class ApplyLeaveLocationTypeChanged extends ApplyLeaveEvent {
  final String locationType;
  const ApplyLeaveLocationTypeChanged(this.locationType);

  @override
  List<Object?> get props => [locationType];
}

class ApplyLeaveSubmitted extends ApplyLeaveEvent {
  const ApplyLeaveSubmitted();
}

class ApplyLeaveReset extends ApplyLeaveEvent {
  const ApplyLeaveReset();
}

class ApplyLeaveHalfDayTargetChanged extends ApplyLeaveEvent {
  final String target;
  const ApplyLeaveHalfDayTargetChanged(this.target);
  @override
  List<Object?> get props => [target];
}

class ApplyLeaveHalfDaySessionChanged extends ApplyLeaveEvent {
  final String session;
  const ApplyLeaveHalfDaySessionChanged(this.session);
  @override
  List<Object?> get props => [session];
}

class ApplyLeaveInitialize extends ApplyLeaveEvent {
  final LeaveRequest? request;
  const ApplyLeaveInitialize(this.request);

  @override
  List<Object?> get props => [request];
}

class ApplyLeaveFileSelected extends ApplyLeaveEvent {
  final File file;
  const ApplyLeaveFileSelected(this.file);

  @override
  List<Object?> get props => [file];
}

class ApplyLeaveFileRemoved extends ApplyLeaveEvent {
  const ApplyLeaveFileRemoved();
}

class ApplyLeaveLoadSubordinates extends ApplyLeaveEvent {
  const ApplyLeaveLoadSubordinates();
}

class ApplyLeaveLoadTypes extends ApplyLeaveEvent {
  final ProfileData? profileData;

  const ApplyLeaveLoadTypes(this.profileData);

  @override
  List<Object?> get props => [profileData];
}

class ApplyLeaveTaskDependencyChanged extends ApplyLeaveEvent {
  final String taskDependency;
  const ApplyLeaveTaskDependencyChanged(this.taskDependency);
  @override
  List<Object?> get props => [taskDependency];
}

class ApplyLeaveDependencyHandleChanged extends ApplyLeaveEvent {
  final String dependencyHandle;
  const ApplyLeaveDependencyHandleChanged(this.dependencyHandle);
  @override
  List<Object?> get props => [dependencyHandle];
}
