import 'package:flutter/material.dart';
import 'package:hrms_ess/utils/responsive_utility.dart';
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';
import '../bloc/leave/leave_bloc.dart';
import '../bloc/leave/leave_event.dart';
import '../bloc/leave/leave_state.dart';
import 'apply_leave_screen.dart';
import '../models/leave/leave_request_model.dart';
import '../models/api/profile_response.dart';
import '../models/api/leave/leave_balance_response.dart';
import '../services/user_context.dart';
import '../models/user_role.dart';
import '../models/api/leave/override_leave_request.dart';
import '../utils/app_colors.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field_new.dart';
import '../widgets/border_container_wraper.dart';
import '../widgets/leave_detail_bottom_sheet.dart';
import '../widgets/leave_expandable_card.dart';

// ─────────────────────────────────────────────
//  CUSTOM WIDGET: Leave Balance Type Card
// ─────────────────────────────────────────────
class LeaveBalanceCard extends StatelessWidget {
  final LeaveBalance balance;

  const LeaveBalanceCard({super.key, required this.balance});

  Color get _cardColor {
    final t = (balance.leaveType ?? '').toLowerCase();
    if (t.contains('casual')) return AppColors.dashboardBlue;
    if (t.contains('sick')) return AppColors.dashboardTeal;
    if (t.contains('birthday')) return AppColors.dashboardPink;
    if (t.contains('comp') || t.contains('off')) return AppColors.dashboardTeal;
    if (t.contains('earned') || t.contains('annual'))
      return AppColors.greenDark;
    if (t.contains('maternity') || t.contains('paternity'))
      return AppColors.dashboardPink;
    return AppColors.primary;
  }

  @override
  Widget build(BuildContext context) {
    final leaveType = balance.leaveType ?? 'Leave';
    final total = (balance.entitled ?? 0).toInt();
    final used = (balance.taken ?? 0).toDouble();
    final remaining = (balance.balance ?? 0).toDouble();

    double actualUsed = used;
    if (actualUsed == 0 && total > 0) {
      actualUsed = total - remaining;
      if (actualUsed < 0) actualUsed = 0;
    }

    final color = _cardColor;
    final lightColor = color.withOpacity(0.10);

    return Container(
      margin: EdgeInsets.only(bottom: 3.w),
      child: LeaveExpandableCard(
        title: '$leaveType ( Total $total )',
        subTitle: actualUsed > 0
            ? 'Used ${actualUsed.toInt()} • Remaining ${remaining.toInt()}'
            : 'Remaining ${remaining.toInt()}',
        headerColor: color,
        borderColor: color.withOpacity(0.18),
        headerHeight: 0.078 * Responsive.getHeight(context),
        collapsedChild: Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.8.w),
          child: Row(
            children: [
              Container(
                width: 10.w,
                height: 10.w,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(_leaveIcon(leaveType), color: color, size: 5.w),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: CustomText(
                  '$leaveType balance details',
                  isKey: false,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
        expandedChild: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: lightColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(12),
              bottomRight: Radius.circular(12),
            ),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  _statCell(
                    'Used Leaves',
                    actualUsed.toInt().toString(),
                    color,
                    Icons.exit_to_app_rounded,
                  ),
                  SizedBox(width: 3.w),
                  _statCell(
                    'Remaining Leaves',
                    remaining.toInt().toString(),
                    color,
                    Icons.event_available_rounded,
                  ),
                ],
              ),
              SizedBox(height: 2.5.w),
              Row(
                children: [
                  _statCell(
                    'Leave Payout',
                    '0',
                    Colors.grey.shade600,
                    Icons.payments_outlined,
                  ),
                  SizedBox(width: 3.w),
                  _statCell(
                    'Carry Forward',
                    '0',
                    Colors.grey.shade600,
                    Icons.forward_rounded,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCell(String label, String value, Color color, IconData icon) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 4.w, color: color),
          SizedBox(width: 2.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  isKey: false,
                  fontSize: 9,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
                CustomText(
                  ': $value',
                  isKey: false,
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _leaveIcon(String type) {
    final t = type.toLowerCase();
    if (t.contains('sick')) return Icons.medical_services_outlined;
    if (t.contains('birthday')) return Icons.cake_outlined;
    if (t.contains('comp') || t.contains('off'))
      return Icons.swap_horiz_rounded;
    if (t.contains('earned') || t.contains('annual'))
      return Icons.beach_access_outlined;
    if (t.contains('maternity')) return Icons.pregnant_woman_outlined;
    if (t.contains('paternity')) return Icons.family_restroom_outlined;
    return Icons.event_note_outlined;
  }
}

// ─────────────────────────────────────────────
//  CUSTOM WIDGET: Leave History Card
// ─────────────────────────────────────────────
class LeaveHistoryCard extends StatelessWidget {
  final LeaveRequest request;
  final VoidCallback? onViewDetails;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const LeaveHistoryCard({
    super.key,
    required this.request,
    this.onViewDetails,
    this.onEdit,
    this.onDelete,
  });

  Color get _headerColor {
    final t = request.type.label.toLowerCase();
    if (t.contains('short')) return AppColors.dashboardTeal;
    if (t.contains('casual')) return AppColors.dashboardBlue;
    if (t.contains('sick')) return AppColors.error;
    if (t.contains('earned') || t.contains('annual'))
      return AppColors.greenDark;
    if (t.contains('optional')) return AppColors.dashboardOrange;
    if (t.contains('auto')) return AppColors.spanishYellow;
    if (t.contains('comp') || t.contains('off')) return AppColors.dashboardTeal;
    if (t.contains('birthday')) return AppColors.dashboardPink;
    return AppColors.primary;
  }

  String get _leaveSubtitle {
    if (request.isHalfDay) return 'Half Day Leave';
    final days = request.totalDays;
    if (days == 1) return 'Full Day Leave';
    return '$days Days Leave';
  }

  @override
  Widget build(BuildContext context) {
    final color = _headerColor;
    final isPending = request.status == LeaveStatus.pending;

    return BorderContainerWraper(
      margin: EdgeInsets.only(bottom: 3.w),
      padding: EdgeInsets.all(0),
      // decoration: BoxDecoration(
      //   color: Colors.white,
      //   borderRadius: BorderRadius.circular(14),
      //   boxShadow: [
      //     BoxShadow(
      //       color: color.withOpacity(0.10),
      //       blurRadius: 10,
      //       offset: const Offset(0, 3),
      //     ),
      //   ],
      // ),
      child: Column(
        children: [
          // ── Colored Date Header ──
          AppShadowContainer(
            borderRadius: 0,
        topLeftRadius: 6,
        topRightRadius: 6,
        innerBottom: true,
        innerBlur: 3,
        backgroundColor:color,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 4.w),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    color: Colors.white,
                    size: 4.w,
                  ),
                  SizedBox(width: 2.w),
                  CustomText(
                    DateFormat('EEE, dd MMM yyyy').format(request.fromDate),
                    isKey: false,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  // Edit & Delete icons (only for pending)
                  if (isPending) ...[
                    GestureDetector(
                      onTap: onEdit,
                      child: Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 4.w,
                        ),
                      ),
                    ),
                    SizedBox(width: 2.w),
                    GestureDetector(
                      onTap: onDelete,
                      child: Container(
                        padding: EdgeInsets.all(1.5.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.20),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.delete_outline_rounded,
                          color: Colors.white,
                          size: 4.w,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Body ──
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Leave type badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.w,
                      ),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: color.withOpacity(0.30)),
                      ),
                      child: CustomText(
                        request.type.label,
                        isKey: false,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    // Leave payment type (Paid/Unpaid)
                    CustomText(
                      _payType(request.type),
                      isKey: false,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
                SizedBox(height: 2.5.w),
                CustomText(
                  _leaveSubtitle,
                  isKey: false,
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                if (request.reason.isNotEmpty) ...[
                  SizedBox(height: 1.5.w),
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        size: 3.5.w,
                        color: Colors.grey.shade400,
                      ),
                      SizedBox(width: 1.5.w),
                      Expanded(
                        child: CustomText(
                          request.reason,
                          isKey: false,
                          fontSize: 10,
                          color: Colors.grey.shade500,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
                SizedBox(height: 3.w),
                Row(
                  children: [
                    // Status badge
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.2.w,
                      ),
                      decoration: BoxDecoration(
                        color: request.status.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 1.5.w,
                            height: 1.5.w,
                            decoration: BoxDecoration(
                              color: request.status.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 1.5.w),
                          CustomText(
                            request.status.label,
                            isKey: false,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: request.status.color,
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    // View Details button
                    GestureDetector(
                      onTap: onViewDetails,
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 3.5.w,
                          vertical: 1.5.w,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: CustomText(
                          'View Details',
                          isKey: false,
                          fontSize: 10,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _payType(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
      case LeaveType.sick:
      case LeaveType.earned:
      case LeaveType.annual:
      case LeaveType.maternity:
      case LeaveType.paternity:
        return 'Paid Leave';
      case LeaveType.eol:
        return 'Unpaid Leave';
    }
  }
}

// ─────────────────────────────────────────────
//  CUSTOM WIDGET: Month Navigator
// ─────────────────────────────────────────────
class MonthNavigator extends StatelessWidget {
  final DateTime currentMonth;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const MonthNavigator({
    super.key,
    required this.currentMonth,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return BorderContainerWraper(
      isShadow: false,
      isBorder: true,
      borderRadius: 12,
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.5.w),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onPrevious,
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_left_rounded,
                color: AppColors.primary,
                size: 5.w,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          CustomText(
            DateFormat('MMMM, yyyy').format(currentMonth),
            isKey: false,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          SizedBox(width: 3.w),
          GestureDetector(
            onTap: onNext,
            child: Container(
              padding: EdgeInsets.all(1.5.w),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                color: AppColors.primary,
                size: 5.w,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CUSTOM WIDGET: Tab Selector (My Leave / Team)
// ─────────────────────────────────────────────
class LeaveSubTabBar extends StatelessWidget {
  final List<String> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabChanged;

  const LeaveSubTabBar({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 10.w,
      padding: EdgeInsets.all(0.8.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final isSelected = i == selectedIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTabChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        i == 0
                            ? Icons.account_balance_wallet_outlined
                            : Icons.people_alt_outlined,
                        size: 3.5.w,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade500,
                      ),
                      SizedBox(width: 1.5.w),
                      CustomText(
                        tabs[i],
                        isKey: false,
                        fontSize: 10,
                        fontWeight: isSelected
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: isSelected
                            ? AppColors.primary
                            : Colors.grey.shade500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  CUSTOM WIDGET: Leave Summary Stats Row
// ─────────────────────────────────────────────
class LeaveSummaryStats extends StatelessWidget {
  final List<LeaveBalance> balances;

  const LeaveSummaryStats({super.key, required this.balances});

  @override
  Widget build(BuildContext context) {
    int totalEntitled = 0;
    int totalUsed = 0;

    for (final b in balances) {
      final entitled = (b.entitled ?? 0).toInt();
      double used = (b.taken ?? 0).toDouble();
      final remaining = (b.balance ?? 0).toDouble();
      if (used == 0 && entitled > 0) {
        used = entitled - remaining;
        if (used < 0) used = 0;
      }
      totalEntitled += entitled;
      totalUsed += used.toInt();
    }

    final remaining = totalEntitled - totalUsed;
    final percent = totalEntitled > 0 ? totalUsed / totalEntitled : 0.0;

    return AppShadowContainer(
      height: 15.h,
      backgroundColor: AppColors.primary,
      innerBottom: true,
      innerBlur: 4,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Circular progress
            SizedBox(
              width: 22.w,
              height: 22.w,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      value: 1.0,
                      strokeWidth: 4.w,
                      color: Colors.white.withOpacity(0.20),
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  SizedBox(
                    width: 22.w,
                    height: 22.w,
                    child: CircularProgressIndicator(
                      value: percent.clamp(0.0, 1.0),
                      strokeWidth: 4.w,
                      color: Colors.white,
                      strokeCap: StrokeCap.round,
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CustomText(
                        '$totalUsed',
                        isKey: false,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      CustomText(
                        'Used',
                        isKey: false,
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.80),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 5.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CustomText(
                    'Leave Summary',
                    isKey: false,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                  SizedBox(height: 3.w),
                  _summaryRow('Total Entitled', '$totalEntitled Days'),
                  SizedBox(height: 1.5.w),
                  _summaryRow('Total Used', '$totalUsed Days'),
                  SizedBox(height: 1.5.w),
                  _summaryRow('Remaining', '$remaining Days'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        CustomText(
          label,
          isKey: false,
          fontSize: 10,
          color: Colors.white.withOpacity(0.75),
          fontWeight: FontWeight.w500,
        ),
        CustomText(
          value,
          isKey: false,
          fontSize: 10,
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────
//  MAIN LEAVE SCREEN
// ─────────────────────────────────────────────
class LeaveScreen extends StatelessWidget {
  final ProfileData? profileData;

  const LeaveScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => LeaveBloc(),
      child: _LeaveScreenContent(profileData: profileData),
    );
  }
}

class _LeaveScreenContent extends StatefulWidget {
  final ProfileData? profileData;

  const _LeaveScreenContent({this.profileData});

  @override
  State<_LeaveScreenContent> createState() => _LeaveScreenContentState();
}

class _LeaveScreenContentState extends State<_LeaveScreenContent>
    with TickerProviderStateMixin {
  late final bool _isManager;
  late final bool _isHR;
  late DateTime _currentDisplayMonth;
  late TabController _mainTabController;
  int _historySubTab = 0; // 0 = My Leaves, 1 = Team (if manager)

  @override
  void initState() {
    _currentDisplayMonth = DateTime.now();
    super.initState();
    final role = UserContext().currentUser?.role ?? UserRole.employee;
    _isManager = role.isManagerial;
    _isHR = role.isHR;

    // Base 2 tabs + 1 for manager + 1 for HR (can be 2, 3, or 4)
    int tabCount = 2;
    if (_isManager) tabCount++;
    if (_isHR) tabCount++;
    _mainTabController = TabController(length: tabCount, vsync: this);

    // NOTE: LeaveBloc constructor already auto-fires LeaveLoadBalances and
    // LeaveLoadHistory — no need to add them again here.
    final bloc = context.read<LeaveBloc>();
    if (_isManager) bloc.add(const LeaveLoadTeamRequests());
    if (_isHR) bloc.add(const LeaveLoadAllLeaves());
  }

  @override
  void dispose() {
    _mainTabController.dispose();
    super.dispose();
  }

  void _navigateToApplyLeave(BuildContext context, LeaveBloc bloc) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyLeaveScreen(profileData: widget.profileData),
      ),
    ).then((result) async {
      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        bloc.add(const LeaveLoadHistory());
        bloc.add(const LeaveLoadBalances());
      }
    });
  }

  void _navigateToEditLeave(
    BuildContext context,
    LeaveBloc bloc,
    LeaveRequest request,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ApplyLeaveScreen(
          editRequest: request,
          profileData: widget.profileData,
        ),
      ),
    ).then((result) async {
      if (result == true) {
        await Future.delayed(const Duration(milliseconds: 500));
        bloc.add(const LeaveLoadHistory());
        bloc.add(const LeaveLoadBalances());
      }
    });
  }

  void _showLeaveDetailsBottomSheet(
    BuildContext context,
    LeaveRequest request,
  ) {
    final color = _historyCardColor(request);
    final requestDate = DateFormat(
      'dd MMM yyyy',
    ).format(request.appliedDate ?? request.fromDate);
    final approvedDate = request.approvalDate != null
        ? DateFormat('dd MMM yyyy').format(request.approvalDate!)
        : '';
    final dayView = request.isHalfDay
        ? 'Half Day'
        : request.totalDays == 1
        ? 'Full Day'
        : '${request.totalDays} Days';

    final attachments =
        request.attachmentUrl != null &&
            request.attachmentUrl!.trim().isNotEmpty
        ? <String>[request.attachmentUrl!.trim()]
        : <String>[];

    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: false,
      backgroundColor: Colors.transparent,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => LeaveDetailBottomSheet(
        leaveDateView:
            '${DateFormat('dd MMM').format(request.fromDate)} - ${DateFormat('dd MMM yyyy').format(request.toDate)}',
        requestDate: requestDate,
        leaveDayView: dayView,
        approvedByName: request.appliedBy ?? '',
        leaveRequestedDate: requestDate,
        approvedDate: approvedDate,
        leaveType: request.type.label,
        leaveDuration: '${request.totalDays} day(s)',
        reason: request.reason,
        altPhone: '',
        taskDependency: request.locationType,
        dependencyHandle: '',
        attachments: attachments,
        status: request.status.label.toUpperCase(),
        detailColor: color,
        autoLeave: request.type.label.toLowerCase().contains('auto'),
        paidUnpaid: _payType(request.type),
        isMultiLevelApproval: false,
        approvalUsers: const [],
      ),
    );
  }

  Color _historyCardColor(LeaveRequest request) {
    final t = request.type.label.toLowerCase();
    if (t.contains('short')) return AppColors.dashboardTeal;
    if (t.contains('casual')) return AppColors.dashboardBlue;
    if (t.contains('sick')) return AppColors.error;
    if (t.contains('earned') || t.contains('annual'))
      return AppColors.greenDark;
    if (t.contains('optional')) return AppColors.dashboardOrange;
    if (t.contains('auto')) return AppColors.spanishYellow;
    if (t.contains('comp') || t.contains('off')) return AppColors.dashboardTeal;
    if (t.contains('birthday')) return AppColors.dashboardPink;
    return AppColors.primary;
  }

  String _payType(LeaveType type) {
    switch (type) {
      case LeaveType.casual:
      case LeaveType.sick:
      case LeaveType.earned:
      case LeaveType.annual:
      case LeaveType.maternity:
      case LeaveType.paternity:
        return 'Paid Leave';
      case LeaveType.eol:
        return 'Unpaid Leave';
    }
  }

  Future<void> _showActionDialog(
    BuildContext context,
    LeaveRequest request,
    bool isApprove,
  ) async {
    final remarkController = TextEditingController();
    final isConfirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(
              isApprove ? Icons.check_circle_outline : Icons.cancel_outlined,
              color: isApprove ? Colors.green : Colors.red,
            ),
            SizedBox(width: 2.w),
            Text(isApprove ? 'Approve Leave' : 'Reject Leave'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Are you sure you want to ${isApprove ? 'approve' : 'reject'} this request?',
            ),
            SizedBox(height: 3.w),
            TextField(
              controller: remarkController,
              decoration: InputDecoration(
                labelText: 'Remark (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 3.w,
                  vertical: 2.w,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: isApprove ? Colors.green : Colors.red,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(isApprove ? 'Approve' : 'Reject'),
          ),
        ],
      ),
    );

    if (isConfirmed == true) {
      if (!context.mounted) return;
      final remark = remarkController.text.trim();
      final bloc = context.read<LeaveBloc>();
      if (isApprove) {
        bloc.add(
          LeaveApproveRequest(request.id, remark.isEmpty ? 'Approved' : remark),
        );
      } else {
        bloc.add(
          LeaveRejectRequest(request.id, remark.isEmpty ? 'Rejected' : remark),
        );
      }
    }
  }

  void _openOverrideDialog(BuildContext context) {
    final employeeIdController = TextEditingController();
    final reasonController = TextEditingController();
    DateTime? fromDate;
    DateTime? toDate;
    String status = "APPROVED";
    LeaveType leaveType = LeaveType.casual;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            title: const CustomText(
              'Override Leave (HR)',
              isKey: false,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  NewTextField(
                    controller: employeeIdController,
                    label: 'Employee ID',
                    hintText: 'Enter employee ID',
                  ),
                  SizedBox(height: 2.w),
                  DropdownButtonFormField<LeaveType>(
                    value: leaveType,
                    items: LeaveType.values
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: CustomText(e.label, isKey: false),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => leaveType = v!),
                    decoration: InputDecoration(
                      labelText: 'Leave Type',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.w),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (d != null) setState(() => fromDate = d);
                          },
                          child: CustomText(
                            fromDate == null
                                ? 'From Date'
                                : DateFormat('yyyy-MM-dd').format(fromDate!),
                            isKey: false,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      Expanded(
                        child: TextButton(
                          onPressed: () async {
                            final d = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                            );
                            if (d != null) setState(() => toDate = d);
                          },
                          child: CustomText(
                            toDate == null
                                ? 'To Date'
                                : DateFormat('yyyy-MM-dd').format(toDate!),
                            isKey: false,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 2.w),
                  DropdownButtonFormField<String>(
                    value: status,
                    items: ["APPROVED", "REJECTED", "PENDING"]
                        .map(
                          (e) => DropdownMenuItem(
                            value: e,
                            child: CustomText(e, isKey: false),
                          ),
                        )
                        .toList(),
                    onChanged: (v) => setState(() => status = v!),
                    decoration: InputDecoration(
                      labelText: 'Status',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  SizedBox(height: 2.w),
                  NewTextField(
                    controller: reasonController,
                    label: 'Remark',
                    hintText: 'Add remark',
                    maxLines: 3,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const CustomText('Cancel', isKey: false),
              ),
              ElevatedButton(
                onPressed: () {
                  if (employeeIdController.text.isEmpty ||
                      fromDate == null ||
                      toDate == null)
                    return;
                  final req = OverrideLeaveRequest(
                    employeeId: employeeIdController.text,
                    leaveType: leaveType.label.toUpperCase(),
                    startDate: DateFormat('yyyy-MM-dd').format(fromDate!),
                    endDate: DateFormat('yyyy-MM-dd').format(toDate!),
                    status: status,
                    remark: reasonController.text,
                  );
                  context.read<LeaveBloc>().add(LeaveOverrideRequest(req));
                  Navigator.pop(ctx);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const CustomText(
                  'Submit',
                  isKey: false,
                  color: Colors.white,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabs = <Tab>[
      const Tab(text: 'Leave Balance'),
      const Tab(text: 'Leave History'),
    ];
    if (_isManager) tabs.add(const Tab(text: 'Team Requests'));
    if (_isHR) tabs.add(const Tab(text: 'All Leaves'));

    return Scaffold(
      backgroundColor: AppColors.bgWhite,
      appBar: _buildAppBar(tabs),
      body: BlocBuilder<LeaveBloc, LeaveState>(
        builder: (context, state) {
          return TabBarView(
            controller: _mainTabController,
            physics: const BouncingScrollPhysics(),
            children: [
              // Tab 1: Leave Balance
              _buildBalanceTab(context, state),
              // Tab 2: Leave History
              _buildHistoryTab(context, state),
              // Tab 3: Team Requests (if manager/HR)
              if (_isManager) _buildTeamTab(context, state, isTeam: true),
              if (_isHR) _buildAllLeavesTab(context, state),
            ],
          );
        },
      ),
      floatingActionButton: Builder(
        builder: (context) {
          final bloc = context.read<LeaveBloc>();
          return AppShadowContainer(
            borderRadius: 50,
            backgroundColor: AppColors.primary,
            innerBottom: true,
            innerLeft: true,
            innerRight: true,
            child: FloatingActionButton(
              onPressed: () => _navigateToApplyLeave(context, bloc),
              shape: const CircleBorder(),
              elevation: 0,
              child: const Icon(Icons.add_rounded, color: Colors.white, size: 40),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(List<Tab> tabs) {
    return AppBar(
      backgroundColor: AppColors.primary,
      elevation: 0,
      iconTheme: const IconThemeData(color: Colors.white),
      title: const CustomText(
        'Leave Management',
        isKey: false,
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),

      bottom: PreferredSize(
        preferredSize: Size.fromHeight(13.w),
        child: Container(
          color: AppColors.primary,
          child: TabBar(
            controller: _mainTabController,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white.withOpacity(0.60),
            indicatorColor: Colors.white,
            indicatorWeight: 3,
            indicatorSize: TabBarIndicatorSize.tab,
            labelStyle: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w700),
            unselectedLabelStyle: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w500,
            ),
            isScrollable: tabs.length > 2,
            tabs: tabs,
          ),
        ),
      ),
    );
  }

  // ─────────────────────── TAB 1: LEAVE BALANCE ───────────────────────
  Widget _buildBalanceTab(BuildContext context, LeaveState state) {
    // Show server error state
    if (state.errorMessage != null &&
        state.leaveBalances.isEmpty &&
        !state.isLoading) {
      return _buildErrorState(
        context: context,
        message:
            'Could not load leave balances.\nPlease check your connection and try again.',
        onRetry: () => context.read<LeaveBloc>().add(const LeaveLoadBalances()),
      );
    }

    if (state.isLoading && state.leaveBalances.isEmpty) {
      return const LeaveBalanceShimmer();
    }

    if (state.leaveBalances.isEmpty) {
      return _buildEmptyState(
        icon: Icons.account_balance_wallet_outlined,
        title: 'No Leave Policy Assigned',
        subtitle:
            'You don\'t have a leave policy assigned yet.\nPlease contact your HR department.',
        color: Colors.orange,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<LeaveBloc>().add(const LeaveLoadBalances());
      },
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.all(2.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Summary stats banner
            LeaveSummaryStats(balances: state.leaveBalances),

            // My Leave / Team selector for history tab hidden here
            // Sub-nav chips for history type
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(1.5.w),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: AppColors.primary,
                    size: 4.5.w,
                  ),
                ),
                SizedBox(width: 2.w),
                CustomText(
                  'My Leave Balance',
                  isKey: false,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
            SizedBox(height: 3.w),

            // Leave balance cards
            ...state.leaveBalances.map((b) => LeaveBalanceCard(balance: b)),

            SizedBox(height: 20.w),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── TAB 2: LEAVE HISTORY ───────────────────────
  Widget _buildHistoryTab(BuildContext context, LeaveState state) {
    final filteredByMonth = state.leaveRequests.where((r) {
      return r.fromDate.month == _currentDisplayMonth.month &&
          r.fromDate.year == _currentDisplayMonth.year;
    }).toList();

    return Column(
      children: [
        // ── Header bar with month nav + sub-tabs ──
        Container(
          color: AppColors.backgroundPrimary,
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
          child: Column(
            children: [
              // My Leaves / Team Leaves sub-tab (shown only if manager)
              if (_isManager) ...[
                LeaveSubTabBar(
                  tabs: const ['My Leaves', 'Team Leaves'],
                  selectedIndex: _historySubTab,
                  onTabChanged: (i) => setState(() => _historySubTab = i),
                ),
                SizedBox(height: 3.w),
              ],
              // Month Navigator
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  MonthNavigator(
                    currentMonth: _currentDisplayMonth,
                    onPrevious: () => setState(() {
                      _currentDisplayMonth = DateTime(
                        _currentDisplayMonth.year,
                        _currentDisplayMonth.month - 1,
                      );
                    }),
                    onNext: () => setState(() {
                      _currentDisplayMonth = DateTime(
                        _currentDisplayMonth.year,
                        _currentDisplayMonth.month + 1,
                      );
                    }),
                  ),
                ],
              ),
            ],
          ),
        ),

        // ── Content ──
        Expanded(
          child: state.isLoading && state.leaveRequests.isEmpty
              ? const LeaveHistoryShimmer()
              : (state.errorMessage != null && state.leaveRequests.isEmpty)
              ? _buildErrorState(
                  context: context,
                  message: 'Could not load leave history.\nPlease try again.',
                  onRetry: () =>
                      context.read<LeaveBloc>().add(const LeaveLoadHistory()),
                )
              : filteredByMonth.isEmpty
              ? _buildEmptyState(
                  icon: Icons.event_busy_outlined,
                  title: 'No Leave Requests',
                  subtitle:
                      'No leave requests found for ${DateFormat('MMMM yyyy').format(_currentDisplayMonth)}.',
                  color: AppColors.primary,
                )
              : RefreshIndicator(
                  onRefresh: () async {
                    context.read<LeaveBloc>().add(const LeaveLoadHistory());
                  },
                  child: ListView.builder(
                    padding: EdgeInsets.fromLTRB(2.w, 2.w, 2.w, 5.w),
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    itemCount: filteredByMonth.length,
                    itemBuilder: (context, index) {
                      final request = filteredByMonth[index];
                      final bloc = context.read<LeaveBloc>();
                      return LeaveHistoryCard(
                        request: request,
                        onEdit: () =>
                            _navigateToEditLeave(context, bloc, request),
                        onDelete: () {},
                        onViewDetails: () =>
                            _showLeaveDetailsBottomSheet(context, request),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  // ─────────────────────── TAB 3: TEAM REQUESTS ───────────────────────
  Widget _buildTeamTab(
    BuildContext context,
    LeaveState state, {
    required bool isTeam,
  }) {
    final requests = isTeam ? state.teamRequests : state.allLeaves;

    if (state.isLoading && requests.isEmpty) {
      return const LeaveHistoryShimmer();
    }

    if (requests.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_alt_outlined,
        title: 'No Team Requests',
        subtitle: 'There are no pending team leave requests at this time.',
        color: AppColors.dashboardTeal,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(2.w),
      itemCount: requests.length,
      itemBuilder: (context, i) {
        final request = requests[i];
        return Container(
          margin: EdgeInsets.only(bottom: 3.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 3.w),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.07),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(14),
                    topRight: Radius.circular(14),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 5.w,
                      backgroundColor: AppColors.primary.withOpacity(0.15),
                      child: CustomText(
                        (request.appliedBy ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        isKey: false,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: CustomText(
                        request.appliedBy ?? 'Unknown Employee',
                        isKey: false,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 3.w,
                        vertical: 1.w,
                      ),
                      decoration: BoxDecoration(
                        color: request.status.color.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: CustomText(
                        request.status.label,
                        isKey: false,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: request.status.color,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(2.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      '${request.type.label} • ${request.reason}',
                      isKey: false,
                      fontSize: 11,
                      color: Colors.grey.shade700,
                    ),
                    SizedBox(height: 2.w),
                    Row(
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 4.w,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 2.w),
                        CustomText(
                          '${DateFormat('MMM dd, yyyy').format(request.fromDate)} → ${DateFormat('MMM dd, yyyy').format(request.toDate)}',
                          isKey: false,
                          fontSize: 11,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ],
                    ),
                    if (request.status == LeaveStatus.pending) ...[
                      SizedBox(height: 3.w),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          _teamActionBtn(
                            'Reject',
                            Colors.red.shade400,
                            () => _showActionDialog(context, request, false),
                          ),
                          SizedBox(width: 3.w),
                          _teamActionBtn(
                            'Approve',
                            Colors.green,
                            () => _showActionDialog(context, request, true),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _teamActionBtn(String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.w),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        child: CustomText(
          label,
          isKey: false,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ─────────────────────── TAB 4: ALL LEAVES (HR) ───────────────────────
  Widget _buildAllLeavesTab(BuildContext context, LeaveState state) {
    return Column(
      children: [
        Container(
          color: Colors.white,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.w),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _openOverrideDialog(context),
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.primary.withOpacity(0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_moderator_rounded,
                          color: AppColors.primary,
                          size: 4.5.w,
                        ),
                        SizedBox(width: 2.w),
                        CustomText(
                          'Override Leave',
                          isKey: false,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 3.w),
              Expanded(
                child: GestureDetector(
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime(2000),
                      lastDate: DateTime(2100),
                    );
                    if (d != null && context.mounted) {
                      context.read<LeaveBloc>().add(LeaveLoadLeavesByDate(d));
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(vertical: 2.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardTeal.withOpacity(0.10),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.dashboardTeal.withOpacity(0.30),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          color: AppColors.dashboardTeal,
                          size: 4.5.w,
                        ),
                        SizedBox(width: 2.w),
                        CustomText(
                          'Filter Date',
                          isKey: false,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: AppColors.dashboardTeal,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(child: _buildTeamTab(context, state, isTeam: false)),
      ],
    );
  }

  // ─────────────────────── EMPTY STATE ───────────────────────
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: color.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 15.w, color: color.withOpacity(0.60)),
            ),
            SizedBox(height: 4.w),
            CustomText(
              title,
              isKey: false,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.w),
            CustomText(
              subtitle,
              isKey: false,
              fontSize: 12,
              color: Colors.grey.shade500,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────── ERROR STATE ───────────────────────
  Widget _buildErrorState({
    required BuildContext context,
    required String message,
    required VoidCallback onRetry,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(8.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.cloud_off_rounded,
                size: 15.w,
                color: Colors.red.shade300,
              ),
            ),
            SizedBox(height: 4.w),
            const CustomText(
              'Something went wrong',
              isKey: false,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 2.w),
            CustomText(
              message,
              isKey: false,
              fontSize: 12,
              color: Colors.grey.shade500,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.w),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.30),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.refresh_rounded,
                      color: Colors.white,
                      size: 4.5.w,
                    ),
                    SizedBox(width: 2.w),
                    const CustomText(
                      'Try Again',
                      isKey: false,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
//  SHIMMER LOADING WIDGETS
// ─────────────────────────────────────────────

class LeaveBalanceShimmer extends StatelessWidget {
  const LeaveBalanceShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(4.w),
      child: Column(
        children: List.generate(
          5,
          (i) => Shimmer.fromColors(
            baseColor: Colors.grey.shade200,
            highlightColor: Colors.white,
            child: Container(
              height: 14.w,
              margin: EdgeInsets.only(bottom: 3.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class LeaveHistoryShimmer extends StatelessWidget {
  const LeaveHistoryShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: EdgeInsets.all(2.w),
      itemCount: 6,
      itemBuilder: (context, i) => Shimmer.fromColors(
        baseColor: Colors.grey.shade200,
        highlightColor: Colors.white,
        child: Container(
          margin: EdgeInsets.only(bottom: 4.w),
          height: i % 2 == 0 ? 35.w : 25.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
