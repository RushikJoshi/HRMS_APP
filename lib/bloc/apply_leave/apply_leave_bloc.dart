import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/api/leave/leave_balance_response.dart';
import '../../models/leave/leave_request_model.dart';
import 'dart:io';

import '../../services/user_context.dart';
import '../../services/leave_service.dart';
import '../../injection/injection.dart';
import 'apply_leave_event.dart';
import 'apply_leave_state.dart';
import '../../api/api.dart';
import '../../models/api/leave/apply_leave_request.dart';

import '../../models/api/employee_option.dart';
import '../leave/leave_bloc.dart';

class ApplyLeaveBloc extends Bloc<ApplyLeaveEvent, ApplyLeaveState> {
  final Api _api = Api();
  final LeaveService _leaveService = LeaveService(apiServices: apiServices);

  ApplyLeaveBloc() : super(const ApplyLeaveState()) {
    on<ApplyLeaveTypeChanged>(_onTypeChanged);
    on<ApplyLeaveRuleChanged>(_onRuleChanged); // New handler
    on<ApplyLeaveFromDateChanged>(_onFromDateChanged);
    on<ApplyLeaveToDateChanged>(_onToDateChanged);
    on<ApplyLeaveReasonChanged>(_onReasonChanged);
    on<ApplyLeaveToggleOnBehalf>(_onToggleOnBehalf);
    on<ApplyLeaveEmployeeSelected>(_onEmployeeSelected);
    on<ApplyLeavePasswordVisibilityToggled>(_onPasswordVisibilityToggled);
    on<ApplyLeaveSubmitted>(_onSubmitted);
    on<ApplyLeaveReset>(_onReset);
    on<ApplyLeaveHalfDayToggled>(_onHalfDayToggled);
    on<ApplyLeaveHalfDayTargetChanged>(_onHalfDayTargetChanged);
    on<ApplyLeaveHalfDaySessionChanged>(_onHalfDaySessionChanged);
    on<ApplyLeaveLocationTypeChanged>(_onLocationTypeChanged);
    on<ApplyLeaveInitialize>(_onInitialize);
    on<ApplyLeaveFileSelected>(_onFileSelected);
    on<ApplyLeaveFileRemoved>(_onFileRemoved);
    on<ApplyLeaveLoadSubordinates>(_onLoadSubordinates);
    on<ApplyLeaveLoadTypes>(_onLoadTypes);
    on<ApplyLeaveTaskDependencyChanged>(_onTaskDependencyChanged);
    on<ApplyLeaveDependencyHandleChanged>(_onDependencyHandleChanged);
  }

  Future<void> _onLoadSubordinates(
    ApplyLeaveLoadSubordinates event,
    Emitter<ApplyLeaveState> emit,
  ) async {
    // Returning Mock Data locally as requested (API removed)
    await Future.delayed(const Duration(milliseconds: 500));
    final subordinates = [
      EmployeeOption(
        id: 'emp_001',
        name: 'Rajesh Kumar',
        employeeId: 'EMP001',
        designation: 'Senior Developer',
      ),
      EmployeeOption(
        id: 'emp_002',
        name: 'Sneha Patel',
        employeeId: 'EMP002',
        designation: 'UI/UX Designer',
      ),
      EmployeeOption(
        id: 'emp_003',
        name: 'Amit Shah',
        employeeId: 'EMP003',
        designation: 'QA Engineer',
      ),
      EmployeeOption(
        id: 'emp_004',
        name: 'Priya Sharma',
        employeeId: 'EMP004',
        designation: 'Flutter Developer',
      ),
    ];
    emit(state.copyWith(subordinates: subordinates));
  }

  Future<void> _onLoadTypes(
    ApplyLeaveLoadTypes event,
    Emitter<ApplyLeaveState> emit,
  ) async {
    print('📋 Loading leave types...');

    try {
      // Use provided profileData first, otherwise fetch from API
      var profileData = event.profileData;

      if (profileData == null) {
        print('   - Fetching profile from API...');
        final response = await _api.getEmployeeProfile();
        profileData = response.data;
      }

      // Extract and emit leave types
      if (profileData?.leavePolicy?.rules != null) {
        final rules = profileData!.leavePolicy!.rules!;
        print('✅ Leave types loaded: ${rules.length} types');
        for (var rule in rules) {
          print('  - ${rule.leaveType} (${rule.color})');
        }
        emit(state.copyWith(availableLeaveTypes: rules));
      } else {
        print('❌ No leave policy rules found in profile data');
        // Emit empty list to avoid blocking the UI
        emit(state.copyWith(availableLeaveTypes: []));
      }
    } catch (e) {
      print('❌ Error loading leave types: $e');
      // Emit empty list on error
      emit(state.copyWith(availableLeaveTypes: []));
    }
  }

  void _onFileSelected(
    ApplyLeaveFileSelected event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(selectedFile: event.file));
  }

  void _onFileRemoved(
    ApplyLeaveFileRemoved event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(clearFile: true));
  }

  void _onInitialize(
    ApplyLeaveInitialize event,
    Emitter<ApplyLeaveState> emit,
  ) {
    if (event.request != null) {
      final req = event.request!;
      print('📝 Initializing edit mode for leave request:');
      print('   ID: ${req.id}');
      print('   Type: ${req.type.label}');
      print('   From: ${req.fromDate}');
      print('   To: ${req.toDate}');
      print('   Reason: ${req.reason}');
      print('   Is Half Day: ${req.isHalfDay}');

      emit(
        state.copyWith(
          selectedLeaveType: req.type,
          fromDate: req.fromDate,
          toDate: req.toDate,
          reason: req.reason,
          isHalfDay: req.isHalfDay,
          locationType: req.locationType,
          leaveId: req.id,
        ),
      );

      print('✅ Edit mode initialized successfully');
    } else {
      print('📝 Initializing new leave application');
    }
  }

  void _onTypeChanged(
    ApplyLeaveTypeChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(selectedLeaveType: event.leaveType));
  }

  void _onRuleChanged(
    ApplyLeaveRuleChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(selectedLeaveRule: event.leaveRule));
  }

  void _onFromDateChanged(
    ApplyLeaveFromDateChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    DateTime? toDate = state.toDate;
    // Reset to date if it's before from date
    if (event.fromDate != null &&
        toDate != null &&
        toDate.isBefore(event.fromDate!)) {
      toDate = null;
    }
    emit(state.copyWith(fromDate: event.fromDate, toDate: toDate));
  }

  void _onToDateChanged(
    ApplyLeaveToDateChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    // Ensure to date is not before from date
    if (state.fromDate != null &&
        event.toDate != null &&
        event.toDate!.isBefore(state.fromDate!)) {
      emit(state.copyWith(errorMessage: 'To date cannot be before from date'));
      return;
    }
    emit(state.copyWith(toDate: event.toDate, errorMessage: null));
  }

  void _onReasonChanged(
    ApplyLeaveReasonChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(reason: event.reason));
  }

  void _onToggleOnBehalf(
    ApplyLeaveToggleOnBehalf event,
    Emitter<ApplyLeaveState> emit,
  ) {
    final newState = !state.isApplyingOnBehalf;
    emit(
      state.copyWith(
        isApplyingOnBehalf: newState,
        selectedEmployee: null, // Reset employee selection
      ),
    );
    if (newState && state.subordinates.isEmpty) {
      add(const ApplyLeaveLoadSubordinates());
    }
  }

  void _onEmployeeSelected(
    ApplyLeaveEmployeeSelected event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(selectedEmployee: event.employeeId));
  }

  void _onPasswordVisibilityToggled(
    ApplyLeavePasswordVisibilityToggled event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }

  void _onHalfDayToggled(
    ApplyLeaveHalfDayToggled event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(isHalfDay: !state.isHalfDay));
  }

  void _onHalfDayTargetChanged(
    ApplyLeaveHalfDayTargetChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(halfDayTarget: event.target));
  }

  void _onHalfDaySessionChanged(
    ApplyLeaveHalfDaySessionChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(halfDaySession: event.session));
  }

  void _onLocationTypeChanged(
    ApplyLeaveLocationTypeChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(locationType: event.locationType));
  }

  Future<void> _onSubmitted(
    ApplyLeaveSubmitted event,
    Emitter<ApplyLeaveState> emit,
  ) async {
    // Validate - check if either selectedLeaveRule or selectedLeaveType is set
    if (state.selectedLeaveRule == null && state.selectedLeaveType == null) {
      emit(state.copyWith(errorMessage: 'Please select a leave type'));
      return;
    }

    if (state.fromDate == null || state.toDate == null) {
      emit(
        state.copyWith(errorMessage: 'Please select both from and to dates'),
      );
      return;
    }

    if (state.reason.isEmpty) {
      emit(state.copyWith(errorMessage: 'Please enter a reason'));
      return;
    }

    emit(state.copyWith(isSubmitting: true, errorMessage: null));

    try {
      // Map halfDaySession from "FN"/"AN" to "Morning"/"Afternoon" as per API spec
      String? mappedHalfDaySession;
      if (state.halfDaySession != null) {
        if (state.halfDaySession == 'FN' || state.halfDaySession == 'First') {
          mappedHalfDaySession = 'Morning';
        } else if (state.halfDaySession == 'AN' ||
            state.halfDaySession == 'Second') {
          mappedHalfDaySession = 'Afternoon';
        } else {
          mappedHalfDaySession = state.halfDaySession; // already correct
        }
      }

      // Determine leave type to send - prefer selectedLeaveRule, fallback to selectedLeaveType
      String leaveTypeToSend;
      if (state.selectedLeaveRule != null) {
        leaveTypeToSend = state.selectedLeaveRule!.leaveType ?? '';
      } else if (state.selectedLeaveType != null) {
        leaveTypeToSend = state.selectedLeaveType!.code;
      } else {
        emit(
          state.copyWith(
            isSubmitting: false,
            errorMessage: 'Invalid leave type',
          ),
        );
        return;
      }

      print('📤 Submitting leave request:');
      print('   Mode: ${state.isEditMode ? "EDIT" : "NEW"}');
      if (state.isEditMode) {
        print('   Leave ID: ${state.leaveId}');
      }
      print('   Leave Type: $leaveTypeToSend');
      print(
        '   Start Date: ${state.fromDate!.toIso8601String().split('T')[0]}',
      );
      print('   End Date: ${state.toDate!.toIso8601String().split('T')[0]}');
      print('   Reason: ${state.reason}');
      print('   Is Half Day: ${state.isHalfDay}');
      print('   Half Day Target: ${state.halfDayTarget}');
      print('   Half Day Session: $mappedHalfDaySession');

      if (state.isEditMode) {
        await _leaveService.editLeave(
          leaveId: state.leaveId!,
          leaveType: leaveTypeToSend,
          startDate: state.fromDate!,
          endDate: state.toDate!,
          reason: state.reason,
          isHalfDay: state.isHalfDay,
          halfDayTarget: state.halfDayTarget,
          halfDaySession: mappedHalfDaySession,
        );
      } else {
        await _leaveService.applyLeave(
          leaveType: leaveTypeToSend,
          startDate: state.fromDate!,
          endDate: state.toDate!,
          reason: state.reason,
          isHalfDay: state.isHalfDay,
          halfDayTarget: state.halfDayTarget,
          halfDaySession: mappedHalfDaySession,
        );
      }

      emit(
        state.copyWith(
          isSubmitting: false,
          successMessage: state.isEditMode
              ? 'Leave updated successfully'
              : 'Leave applied successfully',
        ),
      );
    } catch (e) {
      String errorMessage = 'Failed to submit leave request';

      final errorString = e.toString();

      // Check for specific error patterns
      if (errorString.contains('Balance not found')) {
        errorMessage =
            'Leave balance not found for your account. Please contact HR to set up your leave balance.';
      } else if (errorString.contains('Overlap detected')) {
        errorMessage =
            'Leave dates overlap with an existing request. Please check your leave history and choose different dates.';
      } else if (errorString.contains('NO_LEAVE_POLICY_ASSIGNED')) {
        errorMessage =
            'No leave policy assigned to your account. Please contact HR.';
      } else if (errorString.contains('INSUFFICIENT_BALANCE')) {
        errorMessage =
            'Insufficient leave balance for the selected leave type.';
      } else if (errorString.contains('INVALID_DATE_RANGE')) {
        errorMessage = 'Invalid date range. End date must be after start date.';
      } else if (errorString.contains('403')) {
        errorMessage = 'You do not have permission to perform this action.';
      } else if (errorString.contains('401')) {
        errorMessage = 'Session expired. Please login again.';
      } else if (errorString.contains('500')) {
        errorMessage = 'Server error. Please try again later.';
      }

      print('❌ Leave submission error: $errorMessage');
      print('Original error: $e');

      emit(state.copyWith(isSubmitting: false, errorMessage: errorMessage));
    }
  }

  void _onReset(ApplyLeaveReset event, Emitter<ApplyLeaveState> emit) {
    emit(const ApplyLeaveState());
  }

  void _onTaskDependencyChanged(
    ApplyLeaveTaskDependencyChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(taskDependency: event.taskDependency));
  }

  void _onDependencyHandleChanged(
    ApplyLeaveDependencyHandleChanged event,
    Emitter<ApplyLeaveState> emit,
  ) {
    emit(state.copyWith(dependencyHandle: event.dependencyHandle));
  }
}
