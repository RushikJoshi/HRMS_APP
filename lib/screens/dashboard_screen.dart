import 'dart:ui';
import 'dart:math' as math;
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/custom_timer.dart';
import '../widgets/my_team_section.dart';
import '../widgets/upcoming_celebration_section.dart';
import '../widgets/your_department_section.dart';
import '../widgets/dashboard_app_bar.dart';
import '../utils/app_colors.dart';
import '../widgets/svg_icon.dart';
import '../widgets/common_grid_section.dart';
import '../services/user_context.dart';
import '../models/employee.dart';
import '../models/user_role.dart';
import '../bloc/attendance/attendance_bloc.dart';
import '../bloc/attendance/attendance_event.dart';
import '../bloc/attendance/attendance_state.dart';
import '../bloc/circular/circular_bloc.dart';
import '../widgets/custom_text.dart';

import 'attendance_screen.dart';
import 'my_team_screen.dart';
import 'org_structure_screen.dart';
import 'timesheet_screen.dart';
import 'leave_screen.dart';
import 'payslip_screen.dart';
import 'holiday_calendar_screen.dart';
// import 'location_verification_screen.dart'; // Commented out - using manual punch instead
import 'profile_screen.dart';
import 'circular_screen.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../bloc/my_team/my_team_bloc.dart';
import '../bloc/my_team/my_team_event.dart';
import '../bloc/my_team/my_team_state.dart';
import '../models/api/profile_response.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AttendanceBloc()),
        BlocProvider(create: (context) => CircularBloc()),
        BlocProvider(create: (context) => MyTeamBloc()),
        BlocProvider(
          create: (context) => ProfileBloc()..add(const ProfileLoadRequested()),
        ),
      ],
      child: const _DashboardBootstrap(),
    );
  }
}

class _DashboardBootstrap extends StatefulWidget {
  const _DashboardBootstrap();

  @override
  State<_DashboardBootstrap> createState() => _DashboardBootstrapState();
}

class _DashboardBootstrapState extends State<_DashboardBootstrap> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<AttendanceBloc>().add(const AttendanceSummaryRequested());
      context.read<MyTeamBloc>().add(const MyTeamLoadRequested());
    });
  }

  @override
  Widget build(BuildContext context) => const _DashboardScreenContent();
}

class _DashboardScreenContent extends StatelessWidget {
  const _DashboardScreenContent();

  String _formatDuration(int totalSeconds) {
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _handlePunch(BuildContext context, AttendanceBloc bloc) {
    // Commented out face verification - now using manual punch directly
    // final bool? result = await Navigator.push<bool>(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) =>
    //         LocationVerificationScreen(isPunchIn: !bloc.state.isPunchedIn),
    //   ),
    // );

    // if (result == true) {
    final messenger = ScaffoldMessenger.maybeOf(context);

    if (bloc.state.isPunchedIn) {
      bloc.add(AttendancePunchOutRequested(DateTime.now()));
    } else {
      bloc.add(AttendancePunchInRequested(DateTime.now()));
    }

    if (messenger == null) return;
    messenger.showSnackBar(
      SnackBar(
        content: CustomText(
          !bloc.state.isPunchedIn
              ? 'Punched In successfully!'
              : 'Punched Out successfully!',
          isKey: false,
          color: Colors.white,
        ),
        backgroundColor: AppColors.greenDark,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
    // }
  }

  void _startBreak(
    BuildContext context,
    AttendanceBloc bloc, {
    required int minutes,
    required String type,
  }) {
    bloc.add(AttendanceBreakStarted(breakType: type, durationMinutes: minutes));
  }

  void _endBreak(BuildContext context, AttendanceBloc bloc) {
    bloc.add(const AttendanceBreakEnded());
  }

  void _showBreakOptions(BuildContext context, AttendanceBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return BlocProvider.value(
          value: bloc,
          child: BlocBuilder<AttendanceBloc, AttendanceState>(
            builder: (context, state) {
              return Container(
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                padding: EdgeInsets.all(4.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 10.w,
                        height: 1.w,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 5.w),
                    const CustomText(
                      'Select Break Type',
                      isKey: false,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    SizedBox(height: 5.w),
                    _buildBreakOption(
                      context: bottomSheetContext,
                      svgPath: 'assets/icons/lunch-time.svg',
                      title: 'Lunch Break',
                      duration: '45 minutes',
                      isDisabled: state.lunchTakenToday,
                      onTap: state.lunchTakenToday
                          ? null
                          : () {
                              Navigator.pop(bottomSheetContext);
                              _startBreak(
                                context,
                                bloc,
                                minutes: 45,
                                type: 'Lunch',
                              );
                            },
                    ),
                    SizedBox(height: 3.w),
                    _buildBreakOption(
                      context: bottomSheetContext,
                      svgPath: 'assets/icons/coffee-break.svg',
                      title: 'Short Break',
                      duration: '20 minutes',
                      onTap: () {
                        Navigator.pop(bottomSheetContext);
                        _startBreak(context, bloc, minutes: 20, type: 'Short');
                      },
                    ),
                    SizedBox(height: 5.w),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildBreakOption({
    required BuildContext context,
    IconData? icon,
    String? svgPath,
    required String title,
    required String duration,
    bool isDisabled = false,
    VoidCallback? onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isDisabled ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: EdgeInsets.all(2.5.w),
          decoration: BoxDecoration(
            color: isDisabled ? Colors.grey.shade100 : Colors.blue.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDisabled ? Colors.grey.shade300 : Colors.blue.shade200,
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(2.5.w),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: svgPath != null
                    ? SvgIconWidget(
                        assetPath: svgPath,
                        width: 7.5.w,
                        height: 7.5.w,
                      )
                    : Icon(
                        icon,
                        color: isDisabled
                            ? Colors.grey.shade600
                            : Colors.blue.shade700,
                        size: 7.5.w,
                      ),
              ),
              SizedBox(width: 4.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      title,
                      isKey: false,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDisabled
                          ? Colors.grey.shade600
                          : AppColors.textPrimary,
                    ),
                    const SizedBox(height: 2),
                    CustomText(
                      isDisabled ? 'Already used today' : duration,
                      isKey: false,
                      fontSize: 12,
                      color: isDisabled
                          ? Colors.grey.shade500
                          : Colors.grey.shade700,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 4.w,
                color: isDisabled ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileLoaded) {
          final data = state.profileData;
          final currentUser = UserContext().currentUser;

          UserRole newRole = UserRole.employee;
          bool hasTeam = false;

          final roleText = (data.role ?? data.designation ?? '').toLowerCase();
          final designation = (data.designation ?? '').toLowerCase();

          if (roleText.contains('admin') || roleText.contains('hr')) {
            newRole = UserRole.hr;
            hasTeam = true;
          } else if (roleText.contains('manager') ||
              roleText.contains('head') ||
              roleText.contains('director') ||
              designation.contains('manager') ||
              designation.contains('head')) {
            newRole = UserRole.manager;
            hasTeam = true;
          } else if (roleText.contains('lead') ||
              roleText.contains('supervisor') ||
              designation.contains('lead')) {
            newRole = UserRole.teamLead;
            hasTeam = true;
          }

          if (currentUser != null) {
            if (currentUser.role != newRole || currentUser.hasTeam != hasTeam) {
              final updatedUser = Employee(
                id: data.id ?? currentUser.id,
                name: data.fullName.isNotEmpty
                    ? data.fullName
                    : currentUser.name,
                designation: data.designation ?? currentUser.designation,
                role: newRole,
                hasTeam: hasTeam,
                email: data.email ?? currentUser.email,
                employeeId: data.employeeId ?? currentUser.employeeId,
                companyCode: data.companyCode ?? currentUser.companyCode,
                department: data.department ?? currentUser.department,
                profilePhotoUrl:
                    data.profilePhoto ?? currentUser.profilePhotoUrl,
              );
              UserContext().login(updatedUser);
            }
          }
        }
      },
      child: ListenableBuilder(
        listenable: UserContext(),
        builder: (context, _) {
          final user = UserContext().currentUser;

          if (user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          return Scaffold(
            backgroundColor:  AppColors.backgroundPrimary,
            body: SafeArea(
              child: BlocBuilder<AttendanceBloc, AttendanceState>(
                builder: (context, state) {
                  final bloc = context.read<AttendanceBloc>();
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context, user),
                        _buildPunchSection(context, state, bloc),
                        _buildTeamSection(context),
                        _buildQuickAccessSection(context),
                        _buildCelebrationsSection(context),
                        _buildDepartmentSection(context),
                        SizedBox(height: 25.w),
                      ],
                    ),
                  );
                },
              ),
            ),
            floatingActionButton: Container(
              height: 18.w,
              width: 18.w,
              margin: const EdgeInsets.only(top: 10),
              child: FloatingActionButton(
                onPressed: () {},
                backgroundColor: AppColors.dashboardBlue,
                elevation: 10,
                shape: const CircleBorder(),
                child: Icon(
                  Icons.grid_view_rounded,
                  color: Colors.white,
                  size: 8.w,
                ),
              ),
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerDocked,
            bottomNavigationBar: BottomAppBar(
              height: 18.w,
              shape: const CircularNotchedRectangle(),
              notchMargin: 8,
              color: Colors.white,
              elevation: 20,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    Icons.home_outlined,
                    'Home',
                    true,
                    onTap: () {},
                  ),
                  _buildNavItem(
                    Icons.newspaper_outlined,
                    'Community',
                    false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const OrgStructureScreen(),
                        ),
                      );
                    },
                  ),
                  SizedBox(width: 10.w),
                  _buildNavItem(
                    Icons.chat_bubble_outline,
                    'Chat',
                    false,
                    onTap: () {
                      final circularBloc = context.read<CircularBloc>();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider.value(
                            value: circularBloc,
                            child: const CircularScreen(),
                          ),
                        ),
                      );
                    },
                  ),
                  _buildNavItem(
                    Icons.person_outline,
                    'Profile',
                    false,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProfileScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNavItem(
    IconData icon,
    String label,
    bool isActive, {
    VoidCallback? onTap,
  }) {
    final color = isActive ? AppColors.dashboardBlue : Colors.grey.shade600;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 7.w),
          CustomText(
            label,
            isKey: false,
            fontSize: 10,
            color: color,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Employee user) {
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, profileState) {
        String profileUrl = user.profilePhotoUrl ?? '';
        String designation = user.designation;
        String name = user.name;

        if (profileState is ProfileLoaded) {
          final data = profileState.profileData;
          profileUrl = data.profilePhoto ?? profileUrl;
          designation = data.designation ?? designation;
          name = data.fullName.isNotEmpty ? data.fullName : name;
        }

        return DashboardAppBar(
          userName: name,
          designation: designation,
          profilePictureUrl: profileUrl,
          onProfileTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
        );
      },
    );
  }

  Widget _buildPunchSection(
    BuildContext context,
    AttendanceState state,
    AttendanceBloc bloc,
  ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 5,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: EdgeInsets.all(5.w),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CustomText(
                  state.isPunchedIn ? 'Already Punched IN' : 'Not Punched IN',
                  isKey: false,
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ],
            ),
            SizedBox(height: 6.w),
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: Center(
                    child: CustomTimer(
                      timerWidth: 40.w,
                      timerHeight: 40.w,
                      maxMinutes: 600,
                      minutesPerSegment: 60,
                      initialMinutes: state.totalWorkingSeconds / 60.0,
                      strokeWidth: 15,
                      sectionGap: 2,
                      backgroundColor: Colors.grey.shade100,
                      primaryColor: const [Colors.blueAccent],
                      colorRanges: state.isOnBreak
                          ? [
                              ColorRange(
                                (state.totalWorkingSeconds / 60.0) -
                                    (state.breakRemainingSeconds / 60.0),
                                state.totalWorkingSeconds / 60.0,
                                AppColors.dashboardOrange,
                              ),
                            ]
                          : [],
                    ),
                  ),
                ),
                SizedBox(width: 6.w),
                Expanded(
                  flex: 5,
                  child: Column(
                    children: [
                      _buildActionBtn(
                        label: state.isPunchedIn ? 'Punch Out' : 'Punch In',
                        icon: Icons.access_time,
                        color: state.isPunchedIn
                            ? AppColors.dashboardRed
                            : AppColors.dashboardTeal,
                        onTap: () => _handlePunch(context, bloc),
                      ),
                      if (state.isPunchedIn) ...[
                        SizedBox(height: 3.w),
                        _buildActionBtn(
                          label: state.isOnBreak ? 'End Break' : 'Take a Break',
                          icon: Icons.coffee_outlined,
                          color: AppColors.dashboardOrange,
                          onTap: () => state.isOnBreak
                              ? _endBreak(context, bloc)
                              : _showBreakOptions(context, bloc),
                        ),
                      ],
                      SizedBox(height: 3.w),
                      _buildActionBtn(
                        label: 'My Timecard',
                        icon: Icons.calendar_month_outlined,
                        color: AppColors.dashboardBlue,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const TimesheetScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: AppShadowContainer(
        backgroundColor: color,
        innerTop: false,
        innerBlur: 3,
        innerBottom: true,
        innerLeft: false,
        innerRight: false,

        child: Container(
          height: 12.w,
          padding: EdgeInsets.symmetric(horizontal: 4.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: CustomText(
                  label,
                  isKey: false,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 2.w),
              Icon(icon, color: Colors.white, size: 5.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return BlocBuilder<MyTeamBloc, MyTeamState>(
      builder: (context, state) {
        final List<MyTeamEntity> team = state.allMembers
            .map(
              (m) =>
                  MyTeamEntity(userFullName: m.name, userProfilePic: m.avatar),
            )
            .toList();

        return MyTeamSection(
          myTeam: team,
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyTeamScreen()),
          ),
        );
      },
    );
  }

  Widget _buildQuickAccessSection(BuildContext context) {
    final List<GridItem> items = [
      GridItem(
        label: 'Attendance',
        iconPath: 'assets/icons/attendance.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AttendanceScreen()),
        ),
      ),
      GridItem(
        label: 'Leave',
        iconPath: 'assets/icons/leave.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const LeaveScreen()),
        ),
      ),
      GridItem(
        label: 'Timesheet',
        iconPath: 'assets/icons/timesheet.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const TimesheetScreen()),
        ),
      ),
      GridItem(
        label: 'Payslip',
        iconPath: 'assets/icons/payslip.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const PayslipScreen()),
        ),
      ),
      GridItem(
        label: 'Circular',
        iconPath: 'assets/icons/circular.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => BlocProvider.value(
              value: context.read<CircularBloc>(),
              child: const CircularScreen(),
            ),
          ),
        ),
      ),
      GridItem(
        label: 'Holidays',
        iconPath: 'assets/icons/holidays.svg',
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const HolidayCalendarScreen()),
        ),
      ),
    ];

    return CommonGridSection(
      title: 'Quick Access',
      subtitle: 'Work related tools',
      count: items.length.toString().padLeft(2, '0'),
      useStandardHeader: false,
      items: items,
    );
  }

  Widget _buildCelebrationsSection(BuildContext context) {
    return const UpcomingCelebrationSection(
      birthdays: [], // Data coming from Bloc internally or passed
      onSeeAll: null,
    );
  }

  Widget _buildDepartmentSection(BuildContext context) {
    return BlocBuilder<MyTeamBloc, MyTeamState>(
      builder: (context, state) {
        final List<MyMemberEntity> members = state.allMembers
            .map(
              (m) => MyMemberEntity(
                userFullName: m.name,
                userProfilePic: m.avatar,
                userDesignation: m.designation,
              ),
            )
            .toList();

        return YourDepartmentSection(
          members: members,
          onSeeAll: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const MyTeamScreen()),
          ),
        );
      },
    );
  }
}

