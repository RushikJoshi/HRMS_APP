import 'package:flutter/material.dart';
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import 'border_container_wraper.dart';
import 'custom_text.dart';

// Local model for Birthdays
class TodayBirthDayEntity {
  final String? userFullName;
  final String? userProfilePic;
  final String? userDesignation;
  final String? blockName;
  final String? floorName;
  final String? totalYearView;

  TodayBirthDayEntity({
    this.userFullName,
    this.userProfilePic,
    this.userDesignation,
    this.blockName,
    this.floorName,
    this.totalYearView,
  });
}

class UpcomingCelebrationSection extends StatelessWidget {
  final List<TodayBirthDayEntity>? birthdays;
  final VoidCallback? onSeeAll;

  const UpcomingCelebrationSection({super.key, this.birthdays, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    // Providing default mock data if empty to showcase the premium design on dashboard
    final displayBirthdays = (birthdays == null || birthdays!.isEmpty)
        ? [
            TodayBirthDayEntity(
              userFullName: 'Mayur Chavda',
              userDesignation: 'Flutter Dev',
              blockName: 'WTT',
              floorName: '5th',
              totalYearView: 'Birthday',
            ),
            TodayBirthDayEntity(
              userFullName: 'Jane Doe',
              userDesignation: 'UI Designer',
              blockName: 'WTT',
              floorName: '2nd',
              totalYearView: 'Work Anniv.',
            ),
          ]
        : birthdays;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Upcoming Birthdays',
          subtitle: 'Celebrate someone today',
          count: displayBirthdays!.length.toString().padLeft(2, '0'),
          onSeeAll: onSeeAll,
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          child: Row(
            children: displayBirthdays
                .map(
                  (birthday) => UpcomingCelebrationCard(
                    name: birthday.userFullName ?? '',
                    description:
                        '${birthday.userDesignation ?? ''}\n${birthday.blockName ?? ''}-${birthday.floorName ?? ''}',
                    imagePath:
                        birthday.userProfilePic ??
                        'https://i.pravatar.cc/150?u=${birthday.userFullName.hashCode}',
                    chipLabel: birthday.totalYearView ?? 'Birthday',
                    onButtonPressed: () {},
                  ),
                )
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String count,
    VoidCallback? onSeeAll,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.w),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomText(
                    title,
                    isKey: false,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 2.w,
                      vertical: 0.5.w,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: AppColors.dashboardOrange,
                        width: 0.5,
                      ),
                    ),
                    child: CustomText(
                      count,
                      isKey: false,
                      fontSize: 9,
                      color: AppColors.dashboardOrange,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              CustomText(
                subtitle,
                isKey: false,
                fontSize: 10,
                color: Colors.grey.shade600,
              ),
            ],
          ),
          InkWell(
            onTap: onSeeAll ?? () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.5.w, vertical: 1.5.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F5FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const CustomText(
                'View All',
                isKey: false,
                fontSize: 10,
                color: Color(0xFF0091D5),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class UpcomingCelebrationCard extends StatelessWidget {
  final String name;
  final String description;
  final String imagePath;
  final String chipLabel;
  final VoidCallback onButtonPressed;

  const UpcomingCelebrationCard({
    super.key,
    required this.name,
    required this.description,
    required this.imagePath,
    required this.chipLabel,
    required this.onButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return BorderContainerWraper(
      isShadow: true,
      borderRadius: 20,
      margin: EdgeInsets.only(right: 4.w),
      padding: EdgeInsets.all(2.5.w),
      child: SizedBox(
        width: 55.w,
        child: Column(
          children: [
            // Gift Badge at Top Right
            Align(
              alignment: Alignment.topRight,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.w),
                decoration: BoxDecoration(
                  color: AppColors.dashboardBlue.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.dashboardBlue.withOpacity(0.1),
                    width: 0.5,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.card_giftcard_rounded,
                      size: 3.w,
                      color: AppColors.dashboardBlue,
                    ),
                    SizedBox(width: 1.w),
                    CustomText(
                      chipLabel,
                      isKey: false,
                      fontSize: 9,
                      fontWeight: FontWeight.w900,
                      color: AppColors.dashboardBlue,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 2.w),
            // Profile Photo and Name in One Row
            Row(
              children: [
                // Inner Shadow Profile with directional logic
                AppShadowContainer(
                  height: 10.h,
                  width: 22.w,
                  child: Padding(
                    padding: EdgeInsets.all(0.5.w),
                    child: ClipOval(
                      child: Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (c, e, s) => Container(
                          color: Colors.grey.shade100,
                          child: Icon(
                            Icons.person,
                            color: AppColors.primary,
                            size: 6.w,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 2.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      CustomText(
                        name,
                        isKey: false,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 0.5.w),
                      CustomText(
                        description,
                        isKey: false,
                        fontSize: 8,
                        color: Colors.grey.shade600,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: 2.5.w),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onButtonPressed,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.dashboardBlue,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 1.5.w),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 3,
                  shadowColor: AppColors.dashboardBlue.withOpacity(0.3),
                ),
                child: const CustomText(
                  'Celebrate',
                  isKey: false,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
