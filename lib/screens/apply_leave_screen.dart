import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

import '../services/user_context.dart';
import '../services/permission_service.dart';
import '../widgets/permission_guard.dart';
import '../bloc/apply_leave/apply_leave_bloc.dart';
import '../bloc/apply_leave/apply_leave_event.dart';
import '../bloc/apply_leave/apply_leave_state.dart';
import '../bloc/profile/profile_bloc.dart'; // Added for ProfileBloc
import '../bloc/profile/profile_state.dart'; // Added for ProfileState
import '../models/leave/leave_request_model.dart';
import '../models/api/employee_option.dart';
import '../models/api/profile_response.dart'; // Added for ProfileData
import '../utils/app_icons.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field_new.dart';

class ApplyLeaveScreen extends StatelessWidget {
  final LeaveRequest? editRequest;
  final ProfileData? profileData; // Accept profile data as parameter

  const ApplyLeaveScreen({super.key, this.editRequest, this.profileData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApplyLeaveBloc()
        ..add(ApplyLeaveInitialize(editRequest))
        ..add(
          ApplyLeaveLoadTypes(profileData),
        ), // Load leave types from profile
      child: _ApplyLeaveScreenContent(initialReason: editRequest?.reason),
    );
  }
}

class _ApplyLeaveScreenContent extends StatelessWidget {
  final String? initialReason;
  const _ApplyLeaveScreenContent({this.initialReason});

  @override
  Widget build(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _reasonController = TextEditingController(text: initialReason);

    return BlocListener<ApplyLeaveBloc, ApplyLeaveState>(
      listenWhen: (previous, current) {
        return (previous.isSubmitting && !current.isSubmitting) ||
            (previous.errorMessage != current.errorMessage &&
                current.errorMessage != null);
      },
      listener: (context, state) {
        if (state.errorMessage != null && !state.isSubmitting) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error_outline, color: Colors.white),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(4.w),
            ),
          );
        } else if (!state.isSubmitting && state.errorMessage == null) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      state.successMessage ??
                          'Leave request submitted successfully!',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
              backgroundColor:  AppColors.greenDark,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              margin: EdgeInsets.all(4.w),
            ),
          );
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (context.mounted) Navigator.pop(context, true);
          });
        }
      },
      child: BlocBuilder<ApplyLeaveBloc, ApplyLeaveState>(
        builder: (context, state) {
          final bloc = context.read<ApplyLeaveBloc>();

          Future<void> _selectDate(
            BuildContext context,
            bool isFromDate,
          ) async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: isFromDate
                  ? (state.fromDate ?? DateTime.now())
                  : (state.toDate ?? state.fromDate ?? DateTime.now()),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: AppColors.dashboardBlue,
                      onPrimary: Colors.white,
                      surface: Colors.white,
                      onSurface: AppColors.textColorDark,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (picked != null) {
              if (isFromDate) {
                bloc.add(ApplyLeaveFromDateChanged(picked));
              } else {
                bloc.add(ApplyLeaveToDateChanged(picked));
              }
            }
          }

          Future<void> _handleSubmit() async {
            if (_formKey.currentState!.validate()) {
              bloc.add(const ApplyLeaveSubmitted());
            }
          }

          Widget _buildSelectionOption(
            String label,
            String value,
            String groupValue,
            Function(String) onSelect,
          ) {
            final isSelected = value == groupValue;
            return Expanded(
              child: InkWell(
                onTap: () => onSelect(value),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 2.5.w),
                  decoration: BoxDecoration(
                    color: isSelected
                        ?  AppColors.dashboardBlue.withOpacity(0.1)
                        : Colors.transparent,
                    border: Border.all(
                      color: isSelected
                          ?  AppColors.dashboardBlue
                          : Colors.grey.shade300,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        size: 14.sp,
                        color: isSelected
                            ?  AppColors.dashboardBlue
                            : Colors.grey.shade600,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          color: isSelected
                              ?  AppColors.dashboardBlue
                              : Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor:  AppColors.backgroundPrimary,
            appBar: AppBar(
              title: const CustomText(
                'Apply for Leave',
                isKey: false,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColorDark,
              ),
              backgroundColor: Colors.white,
              elevation: 0,
              iconTheme: const IconThemeData(color: AppColors.textColorDark),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: SingleChildScrollView(
              padding: EdgeInsets.all(4.w),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Main Form Container
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 3.w,
                            offset: Offset(0, 1.h),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Form Header
                          Container(
                            padding: EdgeInsets.all(5.w),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                   AppColors.dashboardBlue.withOpacity(0.08),
                                   AppColors.dashboardBlue.withOpacity(0.02),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(20),
                                topRight: Radius.circular(20),
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color:  AppColors.dashboardBlue,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    Icons.description_rounded,
                                    color: Colors.white,
                                    size: 20.sp,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Leave Application Form',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.textColorDark,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    SizedBox(height: 1.w),
                                    Text(
                                      'Fill in the details below',
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          // Form Fields
                          Padding(
                            padding: EdgeInsets.all(5.w),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Apply On-Behalf Section
                                // Apply On-Behalf Section - Hidden as per user request to simplify UI
                                PermissionGuard(
                                  permission: AppPermission.applyOnBehalfLeave,
                                  child: Column(
                                    children: [
                                      _buildSectionHeader('Application Type'),
                                      const SizedBox(height: 12),
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.grey.shade300,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            14,
                                          ),
                                        ),
                                        child: SwitchListTile(
                                          title: Text(
                                            'Apply On-Behalf',
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12.sp,
                                            ),
                                          ),
                                          subtitle: Text(
                                            'Submit leave for team member',
                                            style: TextStyle(fontSize: 9.sp),
                                          ),
                                          value: state.isApplyingOnBehalf,
                                          activeColor:  AppColors.dashboardBlue,
                                          contentPadding: EdgeInsets.symmetric(
                                            horizontal: 4.w,
                                            vertical: 1.w,
                                          ),
                                          onChanged: (value) {
                                            bloc.add(
                                              const ApplyLeaveToggleOnBehalf(),
                                            );
                                          },
                                        ),
                                      ),
                                      if (state.isApplyingOnBehalf) ...[
                                        SizedBox(height: 4.w),
                                        DropdownButtonFormField<String>(
                                          decoration: _inputDecoration(
                                            'Select Employee *',
                                            Icons.person_search_rounded,
                                          ),
                                          isExpanded: true,
                                          hint: const Text(
                                            'Search or Select Employee',
                                          ),
                                          items: state.subordinates.isEmpty
                                              ? <DropdownMenuItem<String>>[]
                                              : state.subordinates.map<
                                                  DropdownMenuItem<String>
                                                >((e) {
                                                  return DropdownMenuItem<
                                                    String
                                                  >(
                                                    value: e.id,
                                                    child: Text(
                                                      '${e.name} ${e.employeeId != null ? "(${e.employeeId})" : ""}',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  );
                                                }).toList(),
                                          onChanged: (value) {
                                            if (value != null) {
                                              bloc.add(
                                                ApplyLeaveEmployeeSelected(
                                                  value,
                                                ),
                                              );
                                            }
                                          },
                                          value: state.selectedEmployee,
                                          validator: (value) {
                                            if (state.isApplyingOnBehalf &&
                                                (value == null ||
                                                    value.isEmpty)) {
                                              return 'Please select an employee';
                                            }
                                            return null;
                                          },
                                        ),
                                      ],
                                      SizedBox(height: 6.w),
                                    ],
                                  ),
                                ),

                                // Leave Details Section
                                _buildSectionHeader('Leave Details'),
                                SizedBox(height: 4.w),

                                // Show loading or empty state if no leave types
                                if (state.availableLeaveTypes.isEmpty)
                                  Container(
                                    padding: EdgeInsets.all(5.w),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: Colors.orange.shade200,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.orange.withOpacity(0.1),
                                          blurRadius: 10,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.policy_outlined,
                                          size: 40.sp,
                                          color: Colors.orange.shade400,
                                        ),
                                        SizedBox(height: 3.w),
                                        Text(
                                          'No Leave Policy Assigned',
                                          style: TextStyle(
                                            fontSize: 13.sp,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.textPrimary2,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                        SizedBox(height: 2.w),
                                        Text(
                                          'You cannot apply for leave because no leave policy has been assigned to your account. Please contact your HR department.',
                                          style: TextStyle(
                                            fontSize: 10.sp,
                                            color: Colors.grey.shade600,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ],
                                    ),
                                  )
                                else
                                  DropdownButtonFormField<String>(
                                    value: (() {
                                      // Check if selectedLeaveRule matches any available type
                                      if (state.selectedLeaveRule != null) {
                                        final exists = state.availableLeaveTypes
                                            .any(
                                              (r) =>
                                                  r.leaveType ==
                                                  state
                                                      .selectedLeaveRule!
                                                      .leaveType,
                                            );
                                        return exists
                                            ? state.selectedLeaveRule!.leaveType
                                            : null;
                                      }
                                      // Fallback: check selectedLeaveType for edit mode
                                      final currentLabel =
                                          state.selectedLeaveType?.label;
                                      final exists = state.availableLeaveTypes
                                          .any(
                                            (r) => r.leaveType == currentLabel,
                                          );
                                      return exists ? currentLabel : null;
                                    })(),
                                    decoration: _inputDecoration(
                                      'Leave Type *',
                                      Icons.category_rounded,
                                    ),
                                    isExpanded: true,
                                    items: state.availableLeaveTypes.map((
                                      leaveRule,
                                    ) {
                                      return DropdownMenuItem<String>(
                                        value: leaveRule.leaveType,
                                        child: Row(
                                          children: [
                                            Container(
                                              width: 2.w,
                                              height: 2.w,
                                              decoration: BoxDecoration(
                                                color: _parseColor(
                                                  leaveRule.color,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                            SizedBox(width: 2.5.w),
                                            Expanded(
                                              child: Text(
                                                leaveRule.leaveType ??
                                                    'Unknown',
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    }).toList(),
                                    onChanged: (value) {
                                      if (value != null) {
                                        // Find the LeaveRule that matches this value
                                        final leaveRule = state
                                            .availableLeaveTypes
                                            .firstWhere(
                                              (r) => r.leaveType == value,
                                              orElse: () =>
                                                  LeaveRule(leaveType: value),
                                            );
                                        bloc.add(
                                          ApplyLeaveRuleChanged(leaveRule),
                                        );
                                      }
                                    },
                                    validator: (value) => value == null
                                        ? 'Please select leave type'
                                        : null,
                                  ),
                                SizedBox(height: 4.w),
                                // Date Range Section
                                _buildSectionHeader('Duration'),
                                SizedBox(height: 4.w),

                                Row(
                                  children: [
                                    Expanded(
                                      child: NewTextField(
                                        enabled: false,
                                        onTap: () => _selectDate(context, true),
                                        controller: TextEditingController(
                                          text: state.fromDate != null
                                              ? DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(state.fromDate!)
                                              : '',
                                        ),
                                        hintText: 'Start Date *',
                                        prefix: const Icon(
                                          Icons.calendar_today_rounded,
                                        ),
                                        validator: (value) =>
                                            state.fromDate == null
                                            ? 'Required'
                                            : null,
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.all(2.w),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFF1E88E5,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.arrow_forward_rounded,
                                          color:  AppColors.dashboardBlue,
                                          size: 16.sp,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: NewTextField(
                                        enabled: false,
                                        onTap: () =>
                                            _selectDate(context, false),
                                        controller: TextEditingController(
                                          text: state.toDate != null
                                              ? DateFormat(
                                                  'dd MMM yyyy',
                                                ).format(state.toDate!)
                                              : '',
                                        ),
                                        hintText: 'End Date *',
                                        prefix: const Icon(
                                          Icons.calendar_today_rounded,
                                        ),
                                        validator: (value) =>
                                            state.toDate == null
                                            ? 'Required'
                                            : null,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 4.w),

                                // Half Day Toggle
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade300,
                                    ),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Column(
                                    children: [
                                      SwitchListTile(
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 4.w,
                                          vertical: 1.w,
                                        ),
                                        title: Text(
                                          'Half Day Leave',
                                          style: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 12.sp,
                                          ),
                                        ),
                                        subtitle: Text(
                                          'First or second half of the day',
                                          style: TextStyle(fontSize: 9.sp),
                                        ),
                                        value: state.isHalfDay,
                                        activeColor:  AppColors.dashboardBlue,
                                        onChanged: (val) {
                                          bloc.add(
                                            const ApplyLeaveHalfDayToggled(),
                                          );
                                        },
                                      ),
                                      if (state.isHalfDay) ...[
                                        Divider(
                                          height: 1,
                                          color: Colors.grey.shade300,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(4.w),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              if (state.fromDate != null &&
                                                  state.toDate != null &&
                                                  !DateUtils.isSameDay(
                                                    state.fromDate!,
                                                    state.toDate!,
                                                  )) ...[
                                                Text(
                                                  'Apply Half Day On:',
                                                  style: TextStyle(
                                                    fontSize: 10.sp,
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.grey.shade700,
                                                  ),
                                                ),
                                                SizedBox(height: 2.w),
                                                Row(
                                                  children: [
                                                    _buildSelectionOption(
                                                      'Start Date',
                                                      'Start',
                                                      state.halfDayTarget ??
                                                          'Start',
                                                      (val) => bloc.add(
                                                        ApplyLeaveHalfDayTargetChanged(
                                                          val,
                                                        ),
                                                      ),
                                                    ),
                                                    SizedBox(width: 3.w),
                                                    _buildSelectionOption(
                                                      'End Date',
                                                      'End',
                                                      state.halfDayTarget ??
                                                          'Start',
                                                      (val) => bloc.add(
                                                        ApplyLeaveHalfDayTargetChanged(
                                                          val,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 4.w),
                                              ],
                                              Text(
                                                'Select Session:',
                                                style: TextStyle(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.grey.shade700,
                                                ),
                                              ),
                                              SizedBox(height: 2.w),
                                              Row(
                                                children: [
                                                  _buildSelectionOption(
                                                    'First Half',
                                                    'FN',
                                                    state.halfDaySession ??
                                                        'FN',
                                                    (val) => bloc.add(
                                                      ApplyLeaveHalfDaySessionChanged(
                                                        val,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 3.w),
                                                  _buildSelectionOption(
                                                    'Second Half',
                                                    'AN',
                                                    state.halfDaySession ??
                                                        'FN',
                                                    (val) => bloc.add(
                                                      ApplyLeaveHalfDaySessionChanged(
                                                        val,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ),

                                // Total Days Display
                                if (state.totalDays != null) ...[
                                  SizedBox(height: 4.w),
                                  Container(
                                    padding: EdgeInsets.all(4.w),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          const Color(
                                            0xFF1E88E5,
                                          ).withOpacity(0.1),
                                          const Color(
                                            0xFF1E88E5,
                                          ).withOpacity(0.05),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(
                                          0xFF1E88E5,
                                        ).withOpacity(0.3),
                                        width: 0.4.w,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.all(2.5.w),
                                          decoration: const BoxDecoration(
                                            color: AppColors.dashboardBlue,
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.event_available_rounded,
                                            color: Colors.white,
                                            size: 16.sp,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'Total Leave Duration',
                                                style: TextStyle(
                                                  fontSize: 12.sp,
                                                  color: Colors.grey,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 0.5.w),
                                              Text(
                                                '${state.totalDays! % 1 == 0 ? state.totalDays!.toInt() : state.totalDays} ${state.totalDays == 1 ? 'Day' : 'Days'}',
                                                style: TextStyle(
                                                  fontSize: 16.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF1E88E5,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                SizedBox(height: 6.w),

                                // Reason Section
                                _buildSectionHeader('Reason for Leave'),
                                SizedBox(height: 4.w),

                                NewTextField(
                                  controller: _reasonController,
                                  hintText: 'Describe your reason *',
                                  maxLines: 4,
                                  onChange: (value) {
                                    bloc.add(ApplyLeaveReasonChanged(value));
                                  },
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please provide a reason for leave';
                                    }
                                    if (value.length < 10) {
                                      return 'Please provide more details (min 10 characters)';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 5.w),

                                // Alt. Phone Number Section
                                _buildSectionHeader('Alt. Phone Number'),
                                SizedBox(height: 4.w),
                                NewTextField(
                                  hintText: '+91 00000 00000',
                                  prefix: const Icon(Icons.phone_rounded),
                                  validator: (value) {
                                    if (value != null && value.isNotEmpty) {
                                      if (value.length < 10) {
                                        return 'Please enter a valid phone number';
                                      }
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 5.w),

                                // Task Dependency Section
                                _buildSectionHeader('Task Dependency On You?'),
                                SizedBox(height: 4.w),
                                Row(
                                  children: [
                                    _buildSelectionOption(
                                      'YES',
                                      'YES',
                                      state.taskDependency ?? 'NO',
                                      (val) => bloc.add(
                                        ApplyLeaveTaskDependencyChanged(val),
                                      ),
                                    ),
                                    SizedBox(width: 3.w),
                                    _buildSelectionOption(
                                      'NO',
                                      'NO',
                                      state.taskDependency ?? 'NO',
                                      (val) => bloc.add(
                                        ApplyLeaveTaskDependencyChanged(val),
                                      ),
                                    ),
                                  ],
                                ),

                                // Dependency Handle (Conditional)
                                if (state.taskDependency == 'YES') ...[
                                  SizedBox(height: 5.w),
                                  _buildSectionHeader('Dependency Handle'),
                                  SizedBox(height: 4.w),
                                  NewTextField(
                                    hintText:
                                        'How to handle dependency while you are on leave?',
                                    maxLines: 4,
                                    onChange: (value) {
                                      bloc.add(
                                        ApplyLeaveDependencyHandleChanged(
                                          value,
                                        ),
                                      );
                                    },
                                    validator: (value) {
                                      if (state.taskDependency == 'YES' &&
                                          (value == null || value.isEmpty)) {
                                        return 'Please explain how to handle dependency';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                                SizedBox(height: 5.w),

                                // Attachment Section
                                OutlinedButton(
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(
                                              Icons.info_outline,
                                              color: Colors.blue.shade700,
                                            ),
                                            SizedBox(width: 3.w),
                                            const Expanded(
                                              child: Text(
                                                'Attachment feature coming soon',
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        backgroundColor: Colors.blue.shade50,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        margin: EdgeInsets.all(4.w),
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.all(4.w),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 0.4.w,
                                    ),
                                    foregroundColor: Colors.grey.shade700,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.attach_file_rounded,
                                        color: Colors.grey.shade600,
                                      ),
                                      SizedBox(width: 2.5.w),
                                      Flexible(
                                        child: Text(
                                          'Upload Supporting Document (Optional)',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 6.w),

                    // Submit Button
                    ElevatedButton(
                      onPressed: state.isSubmitting ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:  AppColors.dashboardBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 4.5.w),
                        elevation: 0,
                        shadowColor:  AppColors.dashboardBlue.withOpacity(0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        disabledBackgroundColor: Colors.grey.shade300,
                      ),
                      child: state.isSubmitting
                          ? SizedBox(
                              height: 5.5.w,
                              width: 5.5.w,
                              child: CircularProgressIndicator(
                                strokeWidth: 0.6.w,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.send_rounded, size: 16.sp),
                                SizedBox(width: 2.5.w),
                                Text(
                                  'Submit Leave Request',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    SizedBox(height: 4.w),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.dashboardBlue, AppColors.loginPrimaryBlue],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.loginPrimaryBlue.withOpacity(0.3),
            blurRadius: 4.w,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(3.5.w),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.person_rounded, color: Colors.white, size: 22.sp),
          ),
          SizedBox(width: 4.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  UserContext().currentUser?.name ?? 'Admin',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 1.w),
                Text(
                  'Applying on: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLeaveBalanceCard(BuildContext context, ApplyLeaveState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 3.w,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.account_balance_wallet_rounded,
                color: AppColors.dashboardBlue,
                size: 18.sp,
              ),
              SizedBox(width: 2.5.w),
              Text(
                'Leave Balance',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColorDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildBalanceItem(
                  'Annual',
                  '12',
                   AppColors.greenDark,
                ),
              ),
              Container(
                width: 0.25.w,
                height: 10.w,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _buildBalanceItem('Sick', '8',  AppColors.dashboardOrange),
              ),
              Container(
                width: 0.25.w,
                height: 10.w,
                color: Colors.grey.shade200,
              ),
              Expanded(
                child: _buildBalanceItem(
                  'Casual',
                  '6',
                  AppColors.dashboardBlue,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceItem(String label, String count, Color color) {
    return Column(
      children: [
        Text(
          count,
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        SizedBox(height: 1.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 9.sp,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      children: [
        Container(
          width: 1.w,
          height: 5.w,
          decoration: BoxDecoration(
            color:  AppColors.dashboardBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(width: 2.5.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 11.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textColorDark,
          ),
        ),
      ],
    );
  }

  Color _getLeaveTypeColor(LeaveType type) {
    switch (type) {
      case LeaveType.annual:
        return  AppColors.greenDark;
      case LeaveType.sick:
        return  AppColors.dashboardOrange;
      case LeaveType.casual:
        return AppColors.dashboardBlue;
      case LeaveType.maternity:
        return  AppColors.dashboardPink;
      case LeaveType.paternity:
        return  AppColors.dashboardPink;
      default:
        return Colors.grey;
    }
  }

  Color _parseColor(String? colorString) {
    if (colorString == null || colorString.isEmpty) {
      return Colors.grey;
    }

    try {
      // Remove # if present
      String hexColor = colorString.replaceAll('#', '');

      // Add FF for full opacity if not present
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }

      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return Colors.grey; // Fallback color
    }
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        fontSize: 11.sp,
        color: Colors.grey.shade700,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color:  AppColors.dashboardBlue, size: 16.sp),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.dashboardBlue, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.error, width: 2),
      ),
      filled: true,
      fillColor: AppColors.gray5,
      contentPadding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.w),
      errorStyle: TextStyle(fontSize: 9.sp, fontWeight: FontWeight.w500),
    );
  }
}

