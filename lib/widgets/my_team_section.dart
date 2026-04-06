import 'dart:math';

import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

// Local model matching the snippet's expectation
class MyTeamEntity {
  final String? userFullName;
  final String? userProfilePic;

  MyTeamEntity({this.userFullName, this.userProfilePic});
}

class PersonData {
  final String firstName;
  final String lastName;
  final String imagePath;
  final bool isActive;

  PersonData({
    required this.firstName,
    required this.lastName,
    required this.imagePath,
    this.isActive = false,
  });
}

class MyTeamSection extends StatelessWidget {
  final List<MyTeamEntity>? myTeam;
  final VoidCallback? onSeeAll;

  const MyTeamSection({super.key, this.myTeam, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    if (myTeam == null || myTeam!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'My Team',
          subtitle: 'Make it Happen',
          count: myTeam!.length.toString().padLeft(2, '0'),
          onSeeAll: onSeeAll,
        ),
        SizedBox(height: 2.w),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w),
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 4.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: OverlappingPeopleCard(
                people: List.generate(myTeam!.length > 4 ? 4 : myTeam!.length, (index) {
                  final teamMember = myTeam![index];
                  final List<String> names = teamMember.userFullName?.split(' ') ?? ['Team', 'Member'];
                  final String firstName = names.isNotEmpty ? names[0] : '';
                  final String lastName = names.length > 1 ? names.sublist(1).join(' ') : '';
                  
                  // Placeholder logic for activity
                  final bool isActive = index == 0 || index == 2; 

                  return PersonData(
                    firstName: firstName,
                    lastName: lastName,
                    imagePath: teamMember.userProfilePic ?? 'https://i.pravatar.cc/150?u=$index',
                    isActive: isActive,
                  );
                }),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, {required String title, required String subtitle, required String count, VoidCallback? onSeeAll}) {
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
                  Text(title, style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                      border: Border.all(color: AppColors.dashboardOrange, width: 0.5),
                    ),
                    child: Text(count, style: TextStyle(fontSize: 8.sp, color: AppColors.dashboardOrange, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              Text(subtitle, style: TextStyle(fontSize: 9.sp, color: Colors.grey.shade600)),
            ],
          ),
          InkWell(
            onTap: onSeeAll ?? () {},
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.w),
              decoration: BoxDecoration(
                color: const Color(0xFFD2F1FF),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text('View All', style: TextStyle(fontSize: 9.sp, color: const Color(0xFF33A9D6), fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}

class OverlappingPeopleCard extends StatelessWidget {
  final List<PersonData> people;
  final double imageSize;
  final double statusDotSize;
  final double overlapFactor;

  const OverlappingPeopleCard({
    required this.people,
    super.key,
    this.imageSize = 65.0,
    this.statusDotSize = 14.0,
    this.overlapFactor = 48.0,
  });

  @override
  Widget build(BuildContext context) {
    final double calculatedWidth = people.isEmpty ? 0 : (people.length - 1) * overlapFactor + imageSize;

    return SizedBox(
      height: imageSize + 45,
      width: calculatedWidth,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(people.length, (index) {
          final person = people[index];
          final Color statusColor = person.isActive ? const Color(0xFF1CE742) : Colors.red;

          return Positioned(
            left: index * overlapFactor,
            child: SizedBox(
              width: imageSize,
              child: Column(
                children: [
                  SizedBox(
                    width: imageSize,
                    height: imageSize,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                          ),
                          child: ClipOval(
                            child: Image.network(
                              person.imagePath,
                              fit: BoxFit.cover,
                              width: imageSize - 4,
                              height: imageSize - 4,
                              errorBuilder: (c, e, s) => Container(color: Colors.grey.shade200),
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          child: Container(
                            width: statusDotSize,
                            height: statusDotSize,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    person.firstName,
                    style: TextStyle(fontSize: 8.sp, fontWeight: FontWeight.w600, color: Colors.blueGrey.shade800),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        }),
      ).animate().fadeIn(duration: const Duration(milliseconds: 500)),
    );
  }
}

// Simple animation extension if available, otherwise standard
extension on Widget {
   Widget animate() => this; // Placeholder for now
   Widget fadeIn({required Duration duration}) => this;
}
