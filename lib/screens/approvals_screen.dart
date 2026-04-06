import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../bloc/approval/approval_bloc.dart';
import '../bloc/approval/approval_event.dart';
import '../bloc/approval/approval_state.dart';
import '../utils/app_icons.dart';

class ApprovalsScreen extends StatelessWidget {
  const ApprovalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalBloc(),
      child: const _ApprovalsScreenContent(),
    );
  }
}

class _ApprovalsScreenContent extends StatelessWidget {
  const _ApprovalsScreenContent();

  void _handleDecision(BuildContext context, String id, bool approved) {
    final bloc = context.read<ApprovalBloc>();
    bloc.add(ApprovalDecisionMade(requestId: id, approved: approved));
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(approved ? 'Request Approved' : 'Request Rejected'),
        backgroundColor: approved ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundPrimary,
      appBar: AppBar(
        title: const Text('Pending Approvals'),
        backgroundColor: AppColors.bgWhite,
        centerTitle: false,
        elevation: 0,
        foregroundColor: AppColors.textPrimary,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.historyRounded),
            onPressed: () {
              // Navigate to history
            },
          ),
        ],
      ),
      body: BlocBuilder<ApprovalBloc, ApprovalState>(
        builder: (context, state) {
          if (state.pendingRequests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(AppIcons.checkCircleOutline, size: 50.sp, color: AppColors.gray10),
                  SizedBox(height: 4.w),
                  const Text('No Pending Approvals', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(4.w),
            itemCount: state.pendingRequests.length,
            itemBuilder: (context, index) {
              final req = state.pendingRequests[index];
              return _buildApprovalCard(context, req);
            },
          );
        },
      ),
    );
  }

  Widget _buildApprovalCard(BuildContext context, Map<String, dynamic> req) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 2.5.w,
            offset: Offset(0, 1.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  child: Text(
                    req['name'][0],
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        req['name'],
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      Text(
                        'Applied by ${req['appliedBy']}',
                        style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(color: Colors.orange.shade800, fontSize: 9.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),
          Padding(
            padding: EdgeInsets.all(4.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(AppIcons.calendar, size: 12.sp, color: Colors.grey.shade600),
                    SizedBox(width: 2.w),
                    Text(
                      req['dates'],
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        req['type'],
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 9.sp),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 3.w),
                Text(
                  req['reason'],
                  style: TextStyle(color: Colors.grey.shade700, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(4.w, 0, 4.w, 4.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _handleDecision(context, req['id'], false),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                    ),
                    child: const Text('Reject'),
                  ),
                ),
                SizedBox(width: 3.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _handleDecision(context, req['id'], true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: EdgeInsets.symmetric(vertical: 3.w),
                    ),
                    child: const Text('Approve'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
