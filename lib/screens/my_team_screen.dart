import 'package:flutter/material.dart';
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shimmer/shimmer.dart';
import '../utils/app_colors.dart';
import '../bloc/my_team/my_team_bloc.dart';
import '../bloc/my_team/my_team_event.dart';
import '../bloc/my_team/my_team_state.dart';
import '../widgets/custom_text.dart';

const Color _primaryColor = Color(0xFF32DBE6);
const Color _borderColor = Color(0xFFE1E8EF);
const Color _backgroundColor = Color(0xFFFAFBFC);

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

class _MyTeamScreenContent extends StatefulWidget {
  const _MyTeamScreenContent();

  @override
  State<_MyTeamScreenContent> createState() => _MyTeamScreenContentState();
}

class _MyTeamScreenContentState extends State<_MyTeamScreenContent> {
  late TextEditingController _searchController;
  String _selectedBranch = 'Junagadh';
  String _selectedDepartment = 'All Departments';
  String? _selectedEmployeeId; // Track selected employee

  final List<String> _branches = ['Junagadh', 'Ahmedabad'];
  final List<String> _departments = [
    'All Departments',
    'QA Technical',
    'Development',
    'Human Resources',
    'Managerial',
    'Web Designer',
    'President of Sales',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: _buildAppBar(context),
      body: BlocBuilder<MyTeamBloc, MyTeamState>(
        builder: (context, state) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(context),
                // Search Bar
                _buildSearchBar(),
                // Filter Section
                _buildFilterSection(context),
                // Team Grid
                SizedBox(height: 2.w),
                _buildTeamGrid(state),
                SizedBox(height: 4.w),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: _backgroundColor,
      elevation: 0,
      leading: Container(
        margin: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 16.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      title: const CustomText(
        'My Team',
        isKey: false,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary2,
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeaderSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(4.w, 3.w, 4.w, 2.w),
      child: Row(
        children: [
          Icon(Icons.location_on_outlined, size: 5.w, color: _primaryColor),
          SizedBox(width: 2.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomText(
                'Branch',
                isKey: false,
                fontSize: 10,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
              CustomText(
                _selectedBranch,
                isKey: false,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const Spacer(),
          Icon(Icons.people_outline, size: 5.w, color: AppColors.textGrey200),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.5.w),
      child: Container(
        decoration: BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (_) {
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search',
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade500),
            prefixIcon: Icon(
              Icons.search,
              size: 5.w,
              color: Colors.grey.shade500,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 2.w),
          ),
          style: TextStyle(fontSize: 13.sp, color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildFilterSection(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(4.w, 2.w, 4.w, 2.w),
      child: Row(
        children: [
          Expanded(
            child: _buildFilterDropdown(
              label: _selectedBranch,
              onTap: () => _showFilterBottomSheet(context, 'Branch', _branches),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: _buildFilterDropdown(
              label: _selectedDepartment,
              onTap: () =>
                  _showFilterBottomSheet(context, 'Department', _departments),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterDropdown({
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.w),
        decoration: BoxDecoration(
          color: Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _borderColor),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            SizedBox(width: 1.w),
            Icon(
              Icons.expand_more,
              size: 4.5.w,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamGrid(MyTeamState state) {
    // Show loading state with shimmer
    if (state.allMembers.isEmpty && state.filteredMembers.isEmpty) {
      return _buildShimmerGrid();
    }

    final filteredMembers = state.filteredMembers
        .where(
          (member) =>
              _searchController.text.isEmpty ||
              member.name.toLowerCase().contains(
                _searchController.text.toLowerCase(),
              ),
        )
        .toList();

    if (filteredMembers.isEmpty) {
      return _buildEmptyState();
    }

    return AppShadowContainer(
      innerTop: true,
      innerLeft: true,
      innerBottom: true,
      innerRight: true,
      innerColor: AppColors.red,
      innerBlur: 3,


      child: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(4.w, 1.w, 4.w, 2.w),
        child: GridView.builder(
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            childAspectRatio: 1.05,
            crossAxisSpacing: 2.5.w,
            mainAxisSpacing: 2.3.w,
          ),
          itemCount: filteredMembers.length,
          itemBuilder: (context, index) => _buildEmployeeCard(
            filteredMembers[index],
            isSelected: _selectedEmployeeId == filteredMembers[index].id,
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerGrid() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(2.w, 1.w, 2.w, 2.w),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 1.05,
          crossAxisSpacing: 2.5.w,
          mainAxisSpacing: 2.5.w,
        ),
        itemCount: 6,
        itemBuilder: (context, index) => Shimmer.fromColors(
          baseColor: Colors.grey.shade200,
          highlightColor: Colors.grey.shade100,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderColor),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 22.sp * 2,
                  height: 22.sp * 2,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(height: 2.w),
                Container(
                  width: 50.w,
                  height: 8.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                SizedBox(height: 1.w),
                Container(
                  width: 40.w,
                  height: 7.sp,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmployeeCard(TeamMember member, {required bool isSelected}) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedEmployeeId = isSelected ? null : member.id;
        });
        _showEmployeeDetails(member);
      },
      child: AnimatedScale(
        scale: isSelected ? 0.98 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? _primaryColor : _borderColor,
              width: isSelected ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? _primaryColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.02),
                blurRadius: isSelected ? 12 : 8,
                offset: Offset(0, isSelected ? 4 : 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Profile Image with Status Indicator
              Stack(
                children: [
                  CircleAvatar(
                    radius: 22.sp,
                    backgroundColor: member.color.withOpacity(0.12),
                    child: Text(
                      member.avatar,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: member.color,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  // Status Indicator Dot
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 8.sp,
                      height: 8.sp,
                      decoration: BoxDecoration(
                        color: member.checkIn == '-'
                            ? Colors.grey
                            : Colors.green.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 3,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 2.w),
              // Employee Name
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Text(
                  member.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              SizedBox(height: 0.5.w),
              // Employee Role
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 1.w),
                child: Text(
                  member.designation,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 8.5.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(vertical: 10.h, horizontal: 4.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 18.w,
            height: 18.w,
            decoration: BoxDecoration(
              color: Color(0xFFF5F7FA),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_outlined,
              size: 10.w,
              color: Colors.grey.shade400,
            ),
          ),
          SizedBox(height: 3.w),
          CustomText(
            'No employees found',
            isKey: false,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
          SizedBox(height: 1.5.w),
          CustomText(
            'Try adjusting your search or filters',
            isKey: false,
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  void _showFilterBottomSheet(
    BuildContext context,
    String filterType,
    List<String> options,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildFilterBottomSheet(
        filterType,
        options,
        filterType == 'Branch' ? _selectedBranch : _selectedDepartment,
      ),
    );
  }

  Widget _buildFilterBottomSheet(
    String filterType,
    List<String> options,
    String selectedValue,
  ) {
    String tempSelected = selectedValue;

    return StatefulBuilder(
      builder: (context, setState) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.all(4.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CustomText(
                      'Select $filterType',
                      isKey: false,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Icon(
                        Icons.close,
                        size: 6.w,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Search in Filter
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.w),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF5F7FA),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _borderColor),
                  ),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search $filterType',
                      hintStyle: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade500,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        size: 5.w,
                        color: Colors.grey.shade500,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(vertical: 1.8.w),
                    ),
                  ),
                ),
              ),
              // Options List
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  padding: EdgeInsets.all(4.w),
                  itemCount: options.length,
                  itemBuilder: (context, index) {
                    final option = options[index];
                    final isSelected = tempSelected == option;
                    return Padding(
                      padding: EdgeInsets.only(bottom: 2.w),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            tempSelected = option;
                          });
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 3.w,
                            vertical: 2.5.w,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? _primaryColor.withOpacity(0.1)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected ? _primaryColor : _borderColor,
                              width: isSelected ? 2 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              CustomText(
                                option,
                                isKey: false,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? _primaryColor
                                    : AppColors.textPrimary,
                              ),
                              if (isSelected)
                                Icon(
                                  Icons.check_circle,
                                  size: 5.w,
                                  color: _primaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              // Submit Button
              Padding(
                padding: EdgeInsets.all(4.w),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (filterType == 'Branch') {
                        _selectedBranch = tempSelected;
                      } else {
                        _selectedDepartment = tempSelected;
                      }
                    });
                    Navigator.pop(context);
                    this.setState(() {});
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 2.8.w),
                    decoration: BoxDecoration(
                      color: _primaryColor,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: _primaryColor.withOpacity(0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: CustomText(
                        'SUBMIT',
                        isKey: false,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEmployeeDetails(TeamMember member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => _buildEmployeeDetailSheet(member),
    );
  }

  Widget _buildEmployeeDetailSheet(TeamMember member) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.all(4.w),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Center(
              child: Container(
                width: 12.w,
                height: 0.6.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            SizedBox(height: 3.w),
            // Profile Section
            CircleAvatar(
              radius: 35.sp,
              backgroundColor: member.color.withOpacity(0.12),
              child: Text(
                member.avatar,
                style: TextStyle(
                  fontSize: 18.sp,
                  color: member.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            SizedBox(height: 2.5.w),
            CustomText(
              member.name,
              isKey: false,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            SizedBox(height: 0.5.w),
            CustomText(
              member.designation,
              isKey: false,
              fontSize: 13,
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            SizedBox(height: 4.w),
            // Divider
            Divider(color: _borderColor, height: 0),
            SizedBox(height: 3.w),
            // Details Grid
            _buildDetailTile(
              Icons.badge_outlined,
              'Employee ID',
              '#${member.id}',
            ),
            SizedBox(height: 2.w),
            _buildDetailTile(
              Icons.work_outline,
              'Department',
              member.department,
            ),
            SizedBox(height: 2.w),
            _buildDetailTile(
              Icons.check_circle_outline,
              'Status',
              member.status,
              color: member.status == 'Active'
                  ? AppColors.greenDark
                  : Colors.grey.shade600,
            ),
            SizedBox(height: 2.w),
            if (member.checkIn != '-')
              _buildDetailTile(
                Icons.access_time_rounded,
                'Check-in Time',
                member.checkIn,
              ),
            SizedBox(height: 4.w),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailTile(
    IconData icon,
    String label,
    String value, {
    Color? color,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.5.w),
      decoration: BoxDecoration(
        color: Color(0xFFFAFBFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _borderColor),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(2.w),
            decoration: BoxDecoration(
              color: (color ?? _primaryColor).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 4.5.w, color: color ?? _primaryColor),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CustomText(
                  label,
                  isKey: false,
                  fontSize: 10,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 0.5.w),
                CustomText(
                  value,
                  isKey: false,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: color ?? AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
