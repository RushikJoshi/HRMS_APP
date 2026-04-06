import 'package:equatable/equatable.dart';
import '../../models/leave/leave_request_model.dart';
import '../../models/api/employee_option.dart';
import '../../models/api/profile_response.dart'; // For LeaveRule
import 'dart:io';

class ApplyLeaveState extends Equatable {
  final LeaveType?
  selectedLeaveType; // Keep for backward compatibility with edit mode
  final LeaveRule?
  selectedLeaveRule; // New: Store the actual leave rule from policy
  final DateTime? fromDate;
  final DateTime? toDate;
  final String reason;
  final bool isApplyingOnBehalf;
  final String? selectedEmployee;
  final bool obscurePassword;
  final bool isSubmitting;
  final String? errorMessage;
  final File? selectedFile;
  final bool isHalfDay;
  final String locationType;
  final List<EmployeeOption> subordinates;
  final List<LeaveRule> availableLeaveTypes; // Leave types from API
  final String? successMessage;
  final String? leaveId;
  final String? halfDayTarget; // "Start" or "End"
  final String? halfDaySession; // "FN" or "AN"
  final String? taskDependency; // YES or NO
  final String? dependencyHandle;

  const ApplyLeaveState({
    this.selectedLeaveType,
    this.selectedLeaveRule,
    this.fromDate,
    this.toDate,
    this.reason = '',
    this.isApplyingOnBehalf = false,
    this.selectedEmployee,
    this.obscurePassword = true,
    this.isSubmitting = false,
    this.errorMessage,
    this.isHalfDay = false,
    this.locationType = 'In-Land',
    this.successMessage,
    this.leaveId,
    this.halfDayTarget,
    this.halfDaySession,
    this.selectedFile,
    this.subordinates = const <EmployeeOption>[],
    this.availableLeaveTypes = const <LeaveRule>[],
    this.taskDependency,
    this.dependencyHandle,
  });

  bool get isEditMode => leaveId != null;

  double? get totalDays {
    if (fromDate != null && toDate != null) {
      double days = (toDate!.difference(fromDate!).inDays + 1).toDouble();
      if (isHalfDay) {
        return days - 0.5;
      }
      return days;
    }
    return null;
  }

  @override
  List<Object?> get props => [
    selectedLeaveType,
    selectedLeaveRule,
    fromDate,
    toDate,
    reason,
    isApplyingOnBehalf,
    selectedEmployee,
    obscurePassword,
    isSubmitting,
    errorMessage,
    successMessage,
    isHalfDay,
    locationType,
    leaveId,
    halfDayTarget,
    halfDaySession,
    selectedFile,
    subordinates,
    availableLeaveTypes,
    taskDependency,
    dependencyHandle,
  ];

  ApplyLeaveState copyWith({
    LeaveType? selectedLeaveType,
    LeaveRule? selectedLeaveRule,
    DateTime? fromDate,
    DateTime? toDate,
    String? reason,
    bool? isApplyingOnBehalf,
    String? selectedEmployee,
    bool? obscurePassword,
    bool? isSubmitting,
    String? errorMessage,
    String? successMessage,
    bool? isHalfDay,
    String? locationType,
    String? leaveId,
    String? halfDayTarget,
    String? halfDaySession,
    File? selectedFile,
    bool clearFile = false,
    List<EmployeeOption>? subordinates,
    List<LeaveRule>? availableLeaveTypes,
    String? taskDependency,
    String? dependencyHandle,
  }) {
    return ApplyLeaveState(
      selectedLeaveType: selectedLeaveType ?? this.selectedLeaveType,
      selectedLeaveRule: selectedLeaveRule ?? this.selectedLeaveRule,
      fromDate: fromDate ?? this.fromDate,
      toDate: toDate ?? this.toDate,
      reason: reason ?? this.reason,
      isApplyingOnBehalf: isApplyingOnBehalf ?? this.isApplyingOnBehalf,
      selectedEmployee: selectedEmployee ?? this.selectedEmployee,
      obscurePassword: obscurePassword ?? this.obscurePassword,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      errorMessage: errorMessage ?? this.errorMessage,
      successMessage: successMessage ?? this.successMessage,
      isHalfDay: isHalfDay ?? this.isHalfDay,
      locationType: locationType ?? this.locationType,
      leaveId: leaveId ?? this.leaveId,
      halfDayTarget: halfDayTarget ?? this.halfDayTarget,
      halfDaySession: halfDaySession ?? this.halfDaySession,
      selectedFile: clearFile ? null : (selectedFile ?? this.selectedFile),
      subordinates: subordinates ?? this.subordinates,
      availableLeaveTypes: availableLeaveTypes ?? this.availableLeaveTypes,
      taskDependency: taskDependency ?? this.taskDependency,
      dependencyHandle: dependencyHandle ?? this.dependencyHandle,
    );
  }
}
