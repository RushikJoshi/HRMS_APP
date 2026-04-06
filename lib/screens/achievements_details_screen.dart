import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/api/profile_response.dart';

class AchievementsDetailsScreen extends StatelessWidget {
  final ProfileData? profileData;

  const AchievementsDetailsScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    final dynamic additionalInfo = profileData?.additionalInfo;
    final achievements = additionalInfo is Map<String, dynamic>
        ? additionalInfo['achievements'] ?? additionalInfo['achievement']
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements Details'), elevation: 0),
      body: ListView(
        padding: EdgeInsets.all(4.w),
        children: [
          _buildCard(
            context,
            'Achievements',
            (achievements == null || achievements.toString().trim().isEmpty)
                ? 'No achievements details available'
                : achievements.toString(),
          ),
          SizedBox(height: 3.w),
          _buildCard(
            context,
            'Education Summary',
            profileData?.education?.type?.isNotEmpty == true
                ? profileData!.education!.type!
                : 'No education summary available',
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, String value) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(4.w),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 2.w),
          Text(value, style: TextStyle(fontSize: 10.sp)),
        ],
      ),
    );
  }
}
