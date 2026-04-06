import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hrms_ess/widgets/app_inner_shadow.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import 'border_container_wraper.dart';
import 'custom_text.dart';

class ProfileInfoCard extends StatelessWidget {
  final String name;
  final String employeeId;
  final String designation;
  final String location;
  final String profilePhotoUrl;
  final String phone;
  final String email;

  const ProfileInfoCard({
    super.key,
    required this.name,
    required this.employeeId,
    required this.designation,
    required this.location,
    required this.profilePhotoUrl,
    required this.phone,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:  EdgeInsets.fromLTRB( 2.w, 0, 2.w, 0),
      child: BorderContainerWraper(
        isShadow: true,
        padding: EdgeInsets.zero,
        borderRadius: 10,
        child: Column(
          children: [
            // Top Banner - Flush with top and sides
            AppInnerShadow(
              top: true,
              left: true,
              right: true,
              bottom: true,
              borderRadius: 0,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 2.w),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(9),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomText(
                      designation,
                      isKey: false,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 11, // Using normalized sp scaling via CustomText
                    ),
                    CustomText(
                      'World Trade Tower, Sarkhej - Gandhinagar',
                      isKey: false,
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 8.5,
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.all(1.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Avatar with Edit Icon
                  Stack(
                    children: [
                      Container(
                        width: 22.w,
                        height: 22.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey.shade200,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(color: Colors.black12, blurRadius: 10, offset: const Offset(0, 4)),
                          ],
                        ),
                        child: ClipOval(
                          child: profilePhotoUrl.isNotEmpty
                              ? Image.network(profilePhotoUrl, fit: BoxFit.cover)
                              : Center(
                                  child: CustomText(
                                    name.isNotEmpty ? name.substring(0, min(2, name.length)).toUpperCase() : '??',
                                    isKey: false,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(Icons.camera_alt, color: Colors.white, size: 10.sp),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 4.w),
                  // User Details
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CustomText(
                          name,
                          isKey: false,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                        ),
                        SizedBox(height: 1.w),
                        _buildDetailRow('Employee ID :', employeeId),
                        _buildDetailRow('', designation),
                        _buildDetailRow('', location),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 2.w),

            SizedBox(height: 4.w),
            Divider(height: 1, color: Colors.grey.shade100, indent: 4.w, endIndent: 4.w),
            SizedBox(height: 4.w),

            // Contact & Social Section
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4.w),
              child: Column(
                children: [
                  _buildIconTextRow(Icons.phone_outlined, phone),
                  SizedBox(height: 2.w),
                  _buildIconTextRow(Icons.email_outlined, email),
                  SizedBox(height: 4.w),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          _buildSocialIcon(Icons.facebook),
                          _buildSocialIcon(Icons.link),
                          _buildSocialIcon(Icons.close),
                          _buildSocialIcon(Icons.photo_camera),
                          _buildSocialIcon(Icons.chat),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.dashboardBlue.withOpacity(0.3)),
                        ),
                        child: Icon(Icons.mode_edit_outline, color: AppColors.dashboardBlue, size: 14.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 4.w),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    if (value.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.only(bottom: 0.5.w),
      child: RichText(
        text: TextSpan(
          children: [
            if (label.isNotEmpty) TextSpan(text: '$label ', style: TextStyle(color: Colors.grey.shade600, fontSize: 9.sp, fontWeight: FontWeight.w500)),
            TextSpan(text: value, style: TextStyle(color: Colors.black87, fontSize: 9.sp, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  Widget _buildIconTextRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, color: AppColors.dashboardBlue, size: 12.sp),
        SizedBox(width: 3.w),
        CustomText(
          text,
          isKey: false,
          color: Colors.black,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ],
    );
  }

  Widget _buildSocialIcon(IconData icon) {
    return Container(
      margin: EdgeInsets.only(right: 2.w),
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(icon, color: Colors.grey.shade600, size: 12.sp),
    );
  }
}
