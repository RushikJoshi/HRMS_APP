import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../utils/responsive_utility.dart';
import 'common_card.dart';
import 'compatibility_theming.dart';
import 'custom_myco_button.dart';
import 'custom_text.dart';
import 'leave_image_grid_bottom_sheet.dart';
import 'leave_summary_collapsed_chips.dart';
import 'leave_summary_grid.dart';


class ApprovalUserEntity {
  final String? name;
  final String? status;

  const ApprovalUserEntity({this.name, this.status});
}

class LeaveDetailBottomSheet extends StatelessWidget {
  final String leaveDateView;
  final String requestDate;
  final String leaveDayView;
  final String approvedByName;
  final String leaveRequestedDate;
  final String approvedDate;
  final String leaveType;
  final String leaveDuration;
  final String reason;
  final String altPhone;
  final String taskDependency;
  final String dependencyHandle;
  final String status;
  final Color detailColor;
  final List<String> attachments;
  final bool autoLeave;
  final String paidUnpaid;
  final bool isMultiLevelApproval;
  final List<ApprovalUserEntity> approvalUsers;

  const LeaveDetailBottomSheet({
    required this.leaveDateView,
    required this.requestDate,
    required this.leaveDayView,
    required this.approvedByName,
    required this.leaveRequestedDate,
    required this.approvedDate,
    required this.leaveType,
    required this.leaveDuration,
    required this.reason,
    required this.altPhone,
    required this.taskDependency,
    required this.dependencyHandle,
    required this.attachments,
    required this.status,
    required this.detailColor,
    required this.autoLeave,
    required this.paidUnpaid,
    required this.isMultiLevelApproval,
    required this.approvalUsers,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final textScale = Responsive.getResponsiveText(context);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: CommonCard(
            headerColor: detailColor,
            title: leaveDateView,
            secondTitle: _isApproved(status) && approvedByName.isNotEmpty
                ? 'By, $approvedByName'
                : null,
            headerHeight: 0.095 * Responsive.getHeight(context),
            suffixIcon: StatusBadge(
              status: status,
              backgroundColor: detailColor,
              textColor: AppTheme.getColor(context).surface,
              borderColor: AppTheme.getColor(context).surface,
              isAutoLeave: autoLeave,
            ),
            bottomWidget: Column(
              children: [
                _buildDateRow(
                  context,
                  Icons.calendar_month,
                  'Leave Request Date',
                  requestDate,
                ),
                if (_isApproved(status) && approvedDate.isNotEmpty)
                  _buildDateRow(
                    context,
                    Icons.verified,
                    'Leave Approved Date',
                    approvedDate,
                  ),
                _buildTabHeader(context),
                Padding(
                  padding: const EdgeInsets.only(top: 12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabelValueColumn(
                        context,
                        autoLeave ? 'Auto Leave Reason:' : 'Leave Reason:',
                        reason,
                      ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        color: AppColors.gray10,
                      ),
                      if (!autoLeave && altPhone.isNotEmpty)
                        _buildLabelValueRow(
                          context,
                          'Alt. phone Number:',
                          altPhone,
                        ),
                      if (!autoLeave && altPhone.isNotEmpty)
                        const Divider(
                          thickness: 1,
                          height: 1,
                          color: AppColors.gray10,
                        ),
                      _buildLabelValueRow(
                        context,
                        'Task Dependency:',
                        taskDependency,
                      ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        color: AppColors.gray10,
                      ),
                      if (dependencyHandle.isNotEmpty)
                        _buildLabelValueColumn(
                          context,
                          'Dependency Handle:',
                          dependencyHandle,
                        ),
                      if (dependencyHandle.isNotEmpty)
                        const Divider(
                          thickness: 1,
                          height: 1,
                          color: AppColors.gray10,
                        ),
                      if (isMultiLevelApproval && approvalUsers.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CustomText(
                                'Approval Users:',
                                isKey: false,
                                fontWeight: FontWeight.bold,
                                fontSize: 12 * textScale,
                              ),
                              SizedBox(
                                height: 6 * Responsive.getResponsive(context),
                              ),
                              Wrap(
                                spacing: 6,
                                runSpacing: 6,
                                children: approvalUsers
                                    .map(
                                      (user) => ApprovalChip(
                                        name: user.name ?? '',
                                        status: user.status ?? '',
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      const Divider(
                        thickness: 1,
                        height: 1,
                        color: AppColors.gray10,
                      ),
                    ],
                  ),
                ),
                if (attachments.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: LeaveImageGridBottomSheet(
                      imageUrls: attachments,
                      buttonText: 'View Attachments',
                    ),
                  ),
                SizedBox(height: 16 * Responsive.getResponsive(context)),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 38.0,
                    vertical: 10,
                  ),
                  child: MyCoButton(
                    onTap: () => Navigator.pop(context),
                    title: 'CLOSE',
                    isShadowBottomLeft: true,
                    boarderRadius: 50,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isApproved(String value) => value.toUpperCase() == 'APPROVED';

  Widget _buildDateRow(
    BuildContext context,
    IconData icon,
    String label,
    String value,
  ) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final textScale = Responsive.getResponsiveText(context);
    return Padding(
      padding: EdgeInsets.all(8 * Responsive.getResponsive(context)),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18 * Responsive.getResponsive(context),
            color: Colors.grey[700],
          ),
          SizedBox(width: 8 * Responsive.getResponsive(context)),
          CustomText('$label :', isKey: false, fontSize: 13 * textScale),
          SizedBox(width: 4 * Responsive.getResponsive(context)),
          Flexible(
            child: CustomText(
              value,
              isKey: false,
              fontWeight: FontWeight.w500,
              fontSize: 13 * textScale,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabHeader(BuildContext context) {
    final textScale = Responsive.getResponsiveText(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12 * Responsive.getResponsive(context),
            ),
            decoration: BoxDecoration(
              color: detailColor.withOpacity(0.1),
              border: const Border.symmetric(
                horizontal: BorderSide(color: AppColors.gray10, width: 2),
              ),
            ),
            alignment: Alignment.center,
            child: CustomText(
              '$leaveType - $paidUnpaid',
              isKey: false,
              fontSize: 13 * textScale,
              fontWeight: FontWeight.w700,
              color: detailColor,
            ),
          ),
        ),
        SizedBox(
          height: 48 * Responsive.getResponsive(context),
          child: const VerticalDivider(
            color: AppColors.gray10,
            width: 1,
            thickness: 2,
          ),
        ),
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: 12 * Responsive.getResponsive(context),
            ),
            decoration: BoxDecoration(
              color: detailColor.withOpacity(0.1),
              border: const Border.symmetric(
                horizontal: BorderSide(color: AppColors.gray10, width: 2),
              ),
            ),
            alignment: Alignment.center,
            child: CustomText(
              leaveDayView.isNotEmpty && leaveDuration.isNotEmpty
                  ? '$leaveDayView ($leaveDuration)'
                  : leaveDayView,
              isKey: false,
              fontSize: 13 * textScale,
              fontWeight: FontWeight.w700,
              color: detailColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLabelValueRow(BuildContext context, String label, String value) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final textScale = Responsive.getResponsiveText(context);
    return Padding(
      padding: EdgeInsets.all(12 * Responsive.getResponsive(context)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label,
            isKey: false,
            fontSize: 12 * textScale,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(width: 4 * Responsive.getResponsive(context)),
          Expanded(
            child: CustomText(value, isKey: false, fontSize: 12 * textScale),
          ),
        ],
      ),
    );
  }

  Widget _buildLabelValueColumn(
    BuildContext context,
    String label,
    String value,
  ) {
    if (value.trim().isEmpty) return const SizedBox.shrink();
    final textScale = Responsive.getResponsiveText(context);
    return Padding(
      padding: EdgeInsets.all(12 * Responsive.getResponsive(context)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomText(
            label,
            isKey: false,
            fontSize: 12 * textScale,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: 4 * Responsive.getResponsive(context)),
          CustomText(value, isKey: false, fontSize: 12 * textScale),
        ],
      ),
    );
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  final Color borderColor;
  final Color textColor;
  final Color backgroundColor;
  final double? fontSize;
  final bool? isAutoLeave;

  const StatusBadge({
    required this.status,
    required this.borderColor,
    required this.textColor,
    this.backgroundColor = Colors.transparent,
    this.fontSize,
    this.isAutoLeave,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scale = Responsive.getResponsiveText(context);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 12 * Responsive.getResponsive(context),
        vertical: 6 * Responsive.getResponsive(context),
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: CustomText(
        (isAutoLeave ?? false) ? 'Auto Leave' : status,
        isKey: false,
        color: textColor,
        fontSize: (fontSize ?? 12) * scale,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class ApprovalChip extends StatelessWidget {
  final String name;
  final String status;

  const ApprovalChip({required this.name, required this.status, super.key});

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color textColor;

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (status) {
      case '1':
        backgroundColor = colorScheme.secondary.withOpacity(0.2);
        textColor = colorScheme.secondary;
        break;
      case '2':
        backgroundColor = colorScheme.error.withOpacity(0.2);
        textColor = colorScheme.error;
        break;
      default:
        backgroundColor = colorScheme.outline.withOpacity(0.2);
        textColor = colorScheme.onSurfaceVariant;
        break;
    }

    return Chip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomText(name, isKey: false, color: textColor),
          const SizedBox(width: 4),
          Icon(Icons.check, color: textColor, size: 16),
        ],
      ),
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: textColor.withOpacity(0.5)),
        borderRadius: BorderRadius.circular(20),
      ),
    );
  }
}
