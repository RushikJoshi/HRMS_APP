import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../models/api/profile_response.dart';

class PastExperienceScreen extends StatelessWidget {
  final ProfileData? profileData;

  const PastExperienceScreen({super.key, this.profileData});

  @override
  Widget build(BuildContext context) {
    final dynamic additionalInfo = profileData?.additionalInfo;
    final experience = additionalInfo is Map<String, dynamic>
        ? additionalInfo['pastExperience'] ?? additionalInfo['experience']
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Past Experience'), elevation: 0),
      body: Padding(
        padding: EdgeInsets.all(4.w),
        child: Container(
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
                'Experience Details',
                style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700),
              ),
              SizedBox(height: 2.w),
              Text(
                (experience == null || experience.toString().trim().isEmpty)
                    ? 'No past experience details available'
                    : experience.toString(),
                style: TextStyle(fontSize: 10.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
