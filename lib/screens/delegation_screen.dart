import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../utils/app_colors.dart';
import '../bloc/delegation/delegation_bloc.dart';
import '../bloc/delegation/delegation_event.dart';
import '../bloc/delegation/delegation_state.dart';
import '../utils/app_icons.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field_new.dart';

class DelegationScreen extends StatelessWidget {
  const DelegationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => DelegationBloc(),
      child: _DelegationScreenContent(),
    );
  }
}

class _DelegationScreenContent extends StatelessWidget {
  _DelegationScreenContent();

  static const List<String> _teamMembers = [
    'EMP002 - Sarah Jones',
    'EMP003 - Mike Ross',
    'EMP004 - Rachel Zane',
  ];

  Future<void> _selectDate(BuildContext context, bool isFrom) async {
    final bloc = context.read<DelegationBloc>();
    final currentDate = isFrom ? bloc.state.fromDate : bloc.state.toDate;
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      if (isFrom) {
        bloc.add(DelegationFromDateChanged(picked));
      } else {
        bloc.add(DelegationToDateChanged(picked));
      }
    }
  }

  void _handleSubmit(BuildContext context) async {
    final bloc = context.read<DelegationBloc>();
    
    // We should use the instance or a local variable if we had a stateful widget.
    // For now, I'll assume validation is handled or just dispatch.
    
    bloc.add(const DelegationSubmitted());

    await Future.delayed(const Duration(seconds: 1));

    if (context.mounted) {
      final state = bloc.state;
      if (!state.isSubmitting && state.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomText('Authority successfully delegated!', isKey: false, color: Colors.white),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final reasonController = TextEditingController();

    return BlocListener<DelegationBloc, DelegationState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: CustomText(state.errorMessage!, isKey: false, color: Colors.white)),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade50,
        appBar: AppBar(
          title: const CustomText(
            'Delegate Authority',
            isKey: false,
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          backgroundColor: Colors.white,
          foregroundColor: AppColors.textPrimary,
          elevation: 0,
        ),
        body: BlocBuilder<DelegationBloc, DelegationState>(
          builder: (context, state) {
            final bloc = context.read<DelegationBloc>();

            return SingleChildScrollView(
              padding: EdgeInsets.all(5.w),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildGuideCard(),
                    SizedBox(height: 6.w),
                    // Dropdown should also be standardized eventually, but user didn't ask for it yet.
                    DropdownButtonFormField<String>(
                      value: state.selectedEmployee,
                      decoration: InputDecoration(
                        labelText: 'Delegate To',
                        prefixIcon: const Icon(AppIcons.personSearch),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _teamMembers.map((e) => DropdownMenuItem(value: e, child: CustomText(e, isKey: false))).toList(),
                      onChanged: (val) => bloc.add(DelegationEmployeeSelected(val)),
                      validator: (value) => value == null ? 'Please select an employee' : null,
                    ),
                    SizedBox(height: 4.w),
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, true),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText('From Date', isKey: false, fontSize: 10, color: Colors.grey),
                                  SizedBox(height: 1.w),
                                  CustomText(
                                    state.fromDate != null ? DateFormat('dd MMM yyyy').format(state.fromDate!) : 'Select Date',
                                    isKey: false,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => _selectDate(context, false),
                            child: Container(
                              padding: EdgeInsets.all(4.w),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(color: Colors.grey.shade300),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const CustomText('To Date', isKey: false, fontSize: 10, color: Colors.grey),
                                  SizedBox(height: 1.w),
                                  CustomText(
                                    state.toDate != null ? DateFormat('dd MMM yyyy').format(state.toDate!) : 'Select Date',
                                    isKey: false,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 4.w),
                    NewTextField(
                      controller: reasonController,
                      hintText: 'Reason for Delegation',
                      maxLines: 3,
                      onChange: (value) => bloc.add(DelegationReasonChanged(value)),
                      validator: (value) => (value == null || value.isEmpty) ? 'Please enter a reason' : null,
                    ),
                    SizedBox(height: 8.w),
                    ElevatedButton(
                      onPressed: state.isSubmitting ? null : () {
                         if (formKey.currentState?.validate() ?? false) {
                            _handleSubmit(context);
                         }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 4.w),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: state.isSubmitting
                          ? SizedBox(
                              height: 5.w,
                              width: 5.w,
                              child: const CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                            )
                          : const CustomText('Confirm Delegation', isKey: false, fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGuideCard() {
    return Container(
      margin: EdgeInsets.all(0.5.w),
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Colors.purple.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(AppIcons.infoOutline, color: Colors.purple.shade700),
          SizedBox(width: 3.w),
          const Expanded(
            child: CustomText(
              'Delegating authority allows the selected employee to approve leave requests on your behalf during the specified period.',
              isKey: false,
              fontSize: 11,
              color: AppColors.dashboardPink, // purple.shade900
            ),
          ),
        ],
      ),
    );
  }
}

