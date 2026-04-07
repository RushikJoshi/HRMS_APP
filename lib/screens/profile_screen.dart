import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/user_context.dart';
import '../utils/app_colors.dart';
import '../bloc/profile/profile_bloc.dart';
import '../bloc/profile/profile_event.dart';
import '../bloc/profile/profile_state.dart';
import '../widgets/profile_info_card.dart';
import '../widgets/profile_personal_info_card.dart';
import '../models/profile_compat_entities.dart';
import '../models/api/profile_response.dart';
import '../widgets/custom_text.dart';
import '../widgets/logout_confirmation_dialog.dart';
import 'personal_details_screen.dart';
import 'contact_details_screen.dart';
import 'past_experience_screen.dart';
import 'achievements_details_screen.dart';
import 'job_information_screen.dart';
import 'education_details_screen.dart';
import 'bank_details_screen.dart';
import 'documents_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileBloc()..add(const ProfileLoadRequested()),
      child: Scaffold(
        backgroundColor:  AppColors.backgroundPrimary,
        appBar: _buildAppBar(context),
        body: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoading && state is! ProfileLoaded) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ProfileError) {
              return Center(child: CustomText(state.message, isKey: false));
            }

            final user = UserContext().currentUser;
            final profileData = state is ProfileLoaded
                ? state.profileData
                : null;

            final List<ProfileMenuEntity> personalInfoItems = [
              ProfileMenuEntity(
                languageKeyName: 'Personal Details',
                profileMenuPhoto: 'assets/icons/delegation.svg',
                menuClick: 'personal',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Contact Details',
                profileMenuPhoto: 'assets/icons/profile.svg',
                menuClick: 'contact',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Achievements Details',
                profileMenuPhoto: 'assets/icons/documentation.svg',
                menuClick: 'achievements',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Past Experience',
                profileMenuPhoto: 'assets/icons/timesheet.svg',
                menuClick: 'experience',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Employment Details',
                profileMenuPhoto: 'assets/icons/resume.svg',
                menuClick: 'employment',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Education Details',
                profileMenuPhoto: 'assets/icons/documentation.svg',
                menuClick: 'education',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Bank Details',
                profileMenuPhoto: 'assets/icons/payslip.svg',
                menuClick: 'bank',
              ),
              ProfileMenuEntity(
                languageKeyName: 'Documents',
                profileMenuPhoto: 'assets/icons/documentation.svg',
                menuClick: 'documents',
              ),
            ];

            return SingleChildScrollView(
              child: Column(
                children: [
                  ProfileInfoCard(
                    name: profileData?.fullName ?? user?.name ?? 'User',
                    employeeId:
                        profileData?.employeeId ??
                        user?.employeeId ??
                        'ESS-000',
                    designation:
                        profileData?.designation ??
                        user?.designation ??
                        'Employee',
                    location: 'World Trade Tower, Sarkhej - Gandhinagar',
                    profilePhotoUrl:
                        profileData?.profilePhoto ??
                        user?.profilePhotoUrl ??
                        '',
                    phone: profileData?.phone ?? '+91-9824798227',
                    email:
                        profileData?.email ??
                        user?.email ??
                        'mayurchavda1210@gmail.com',
                  ),
                  SizedBox(height: 2.w),
                  ProfilePersonalInfoCard(
                    personalInfoList: personalInfoItems,
                    profileModelEntity: ProfileModelEntity(
                      id: '1',
                      fullName: profileData?.fullName ?? 'User',
                    ),
                    onMenuTap: (item) {
                      _onProfileMenuTap(context, item.menuClick, profileData);
                    },
                  ),
                  SizedBox(height: 5.w),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_rounded,
          color: AppColors.textPrimary,
          size: 18.sp,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const CustomText(
        'My Profile',
        isKey: false,
        fontSize: 18,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
      ),
      actions: [
        _buildAppBtn(
          Icons.settings_outlined,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SettingsScreen()),
            );
          },
        ),
        _buildAppBtn(Icons.share_outlined),
        _buildAppBtn(
          Icons.logout_outlined,
          color: Colors.cyan.shade600,
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const LogoutConfirmationDialog(),
            );
          },
        ),
        SizedBox(width: 4.w),
      ],
    );
  }

  Widget _buildAppBtn(IconData icon, {Color? color, VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        margin: EdgeInsets.only(left: 2.w),
        width: 10.w,
        height: 10.w,
        decoration: BoxDecoration(
          color: Colors.cyan.shade50,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color ?? Colors.cyan.shade600, size: 5.5.w),
      ),
    );
  }

  void _onProfileMenuTap(
    BuildContext context,
    String? menuClick,
    ProfileData? profileData,
  ) {
    late final Widget screen;

    switch (menuClick) {
      case 'personal':
        screen = PersonalDetailsScreen(profileData: profileData);
        break;
      case 'contact':
        screen = ContactDetailsScreen(profileData: profileData);
        break;
      case 'experience':
        screen = PastExperienceScreen(profileData: profileData);
        break;
      case 'achievements':
        screen = AchievementsDetailsScreen(profileData: profileData);
        break;
      case 'employment':
        screen = JobInformationScreen(profileData: profileData);
        break;
      case 'education':
        screen = EducationDetailsScreen(profileData: profileData);
        break;
      case 'bank':
        screen = BankDetailsScreen(profileData: profileData);
        break;
      case 'documents':
        screen = DocumentsScreen(profileData: profileData);
        break;
      default:
        return;
    }

    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }
}

