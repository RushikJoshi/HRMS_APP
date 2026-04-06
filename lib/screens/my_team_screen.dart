import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../bloc/my_team/my_team_bloc.dart';
import '../bloc/my_team/my_team_event.dart';
import '../bloc/my_team/my_team_state.dart';

class MyTeamScreen extends StatelessWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => MyTeamBloc(),
      child: const _MyTeamScreenContent(),
    );
  }
}

class _MyTeamScreenContent extends StatelessWidget {
  const _MyTeamScreenContent();

  void _showFilterDialog(BuildContext context) {
    final bloc = context.read<MyTeamBloc>();
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return BlocBuilder<MyTeamBloc, MyTeamState>(
          builder: (context, state) {
            return Container(
              padding: EdgeInsets.all(5.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Filter by Status',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildFilterOption(context, bloc, 'All', state.selectedFilter),
                  _buildFilterOption(context, bloc, 'Present', state.selectedFilter),
                  _buildFilterOption(context, bloc, 'On Leave', state.selectedFilter),
                  _buildFilterOption(context, bloc, 'Late', state.selectedFilter),
                  _buildFilterOption(context, bloc, 'Work from Home', state.selectedFilter),
                  SizedBox(height: 2.5.w),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterOption(BuildContext context, MyTeamBloc bloc, String status, String selectedFilter) {
    final isSelected = selectedFilter == status;
    return ListTile(
      title: Text(status),
      leading: Radio<String>(
        value: status,
        groupValue: selectedFilter,
        onChanged: (value) {
          bloc.add(MyTeamFilterChanged(value!));
          Navigator.pop(context);
        },
      ),
      onTap: () {
        bloc.add(MyTeamFilterChanged(status));
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('My Team'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(AppIcons.filter),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocBuilder<MyTeamBloc, MyTeamState>(
        builder: (context, state) {
          return Scrollbar(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Container(
                  width: 250.w, // Ensure ample width for table, forcing scroll on mobile
                  padding: EdgeInsets.all(4.w),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                       Container(
                         decoration: BoxDecoration(
                           border: Border.all(color: Colors.grey.shade200),
                           borderRadius: BorderRadius.circular(12),
                         ),
                         child: Column(
                           children: [
                             _buildTableHeader(),
                             ...state.filteredMembers.map((member) => _buildTableRow(member)),
                           ],
                         ),
                       ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.w, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        children: [
          _buildHeaderCell('# ID', width: 25.w),
          _buildHeaderCell('Name', width: 60.w, icon: Icons.person_outline),
          _buildHeaderCell('Role', width: 50.w, icon: Icons.work_outline),
          _buildHeaderCell('Department', width: 60.w, icon: Icons.apartment),
          _buildHeaderCell('Status', width: 35.w, icon: Icons.show_chart),
        ],
      ),
    );
  }

  Widget _buildTableRow(TeamMember member) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 3.w, horizontal: 4.w),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 25.w,
            child: Text(
              '#${member.id}',
              style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.bold, color: Colors.grey.shade800),
            ),
          ),
          SizedBox(
            width: 60.w,
            child: Row(
              children: [
                 CircleAvatar(
                    radius: 12,
                    backgroundColor: member.color.withOpacity(0.2),
                    child: Text(member.avatar, style: TextStyle(fontSize: 10.sp, color: member.color, fontWeight: FontWeight.bold)),
                 ),
                 SizedBox(width: 3.w),
                 Text(
                   member.name,
                   style: TextStyle(fontSize: 11.sp, fontWeight: FontWeight.w600, color: Colors.black87),
                 ),
              ],
            ),
          ),
          SizedBox(
            width: 50.w,
            child: Text(
              member.designation,
              style: TextStyle(fontSize: 11.sp, color: Colors.black87, fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            width: 60.w,
            child: Text(
              member.department,
              style: TextStyle(fontSize: 11.sp, color: Colors.black87),
            ),
          ),
          SizedBox(
            width: 35.w,
            child: _buildStatusBadge(member.status),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCell(String text, {required double width, IconData? icon}) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          if (icon != null) ...[Icon(icon, size: 14.sp, color: Colors.grey.shade600), SizedBox(width: 1.5.w)],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          Icon(Icons.unfold_more, size: 12.sp, color: Colors.grey.shade400)
        ],
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    Color textColor = Colors.white;
    switch (status.toLowerCase()) {
      case 'active':
        color = const Color(0xFF8BC34A); // Greenish
        break;
      case 'invited':
        color = const Color(0xFF1F2937); // Dark
        break;
      case 'inactive':
        color = Colors.grey.shade400; // Grey
        break;
      default:
        color = Colors.blue;
    }

    return Row(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
               if (status.toLowerCase() == 'active' || status.toLowerCase() == 'invited') 
                  Icon(status.toLowerCase() == 'invited' ? Icons.check : Icons.circle, 
                       size: 8, color: Colors.white),
               SizedBox(width: 1.w),
               Text(
                status,
                style: TextStyle(color: textColor, fontSize: 10.sp, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
