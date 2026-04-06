import 'dart:math';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import 'custom_text.dart';

// Local model for Department Members
class MyMemberEntity {
  final String? userFullName;
  final String? userProfilePic;
  final String? userDesignation;

  MyMemberEntity({
    this.userFullName,
    this.userProfilePic,
    this.userDesignation,
  });
}

class YourDepartmentSection extends StatelessWidget {
  final List<MyMemberEntity>? members;
  final VoidCallback? onSeeAll;

  const YourDepartmentSection({super.key, this.members, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    if (members?.isEmpty ?? true) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          context,
          title: 'Your Department',
          subtitle: 'The people who help make things happen',
          count: members?.length.toString().padLeft(2, '0') ?? '0',
          onSeeAll: onSeeAll,
        ),
        SizedBox(height: 1.w),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.w),
          child: Row(
            children: members!.map((member) => Padding(
              padding: EdgeInsets.only(right: 5.w),
              child: ProfileCard(
                imagePath: member.userProfilePic ?? 'https://i.pravatar.cc/150?u=${member.userFullName.hashCode}',
                name: member.userFullName ?? '',
                department: member.userDesignation ?? '',
              ),
            )).toList(),
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
                   CustomText(
                    title,
                    isKey: false,
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textPrimary,
                  ),
                  SizedBox(width: 2.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.5.w),
                    decoration: BoxDecoration(
                      color: AppColors.dashboardOrange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.dashboardOrange, width: 0.5),
                    ),
                    child: CustomText(
                      count,
                      isKey: false,
                      fontSize: 8,
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

class ProfileCard extends StatelessWidget {
  final String imagePath;
  final String name;
  final String department;

  const ProfileCard({
    super.key,
    required this.imagePath,
    required this.name,
    required this.department,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32.w,
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.only(bottom: 2.w),
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                CustomPaint(
                  size: Size(32.w, 36.w),
                  painter: DiagonalCornerPainter(
                    fillColor: AppColors.dashboardTeal.withOpacity(0.08),
                    shadowColor: Colors.black.withOpacity(0.04),
                    blur: 6,
                    borderRadius: 15,
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 4.w, bottom: 2.w),
                      child: Container(
                        width: 20.w,
                        height: 20.w,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            imagePath,
                            fit: BoxFit.cover,
                            errorBuilder: (c, e, s) => Container(color: Colors.grey.shade100, child: Icon(Icons.person, color: AppColors.primary, size: 8.w)),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: CustomText(
                        name,
                        isKey: false,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2.w),
                      child: CustomText(
                        department,
                        isKey: false,
                        fontSize: 8,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade600,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class DiagonalCornerPainter extends CustomPainter {
  final Color fillColor;
  final Color shadowColor;
  final double blur;
  final double borderRadius;
  final Offset shadowOffset;

  DiagonalCornerPainter({
    required this.fillColor,
    required this.shadowColor,
    this.blur = 6.0,
    this.borderRadius = 15.0,
    this.shadowOffset = const Offset(0, 4),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final Path shapePath = Path()
      ..moveTo(borderRadius, 0)
      ..lineTo(size.width - borderRadius, 0)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(size.width - borderRadius, borderRadius),
          radius: borderRadius,
        ),
        -pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(borderRadius, size.height)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(borderRadius, size.height - borderRadius),
          radius: borderRadius,
        ),
        pi / 2,
        pi / 2,
        false,
      )
      ..lineTo(0, borderRadius)
      ..arcTo(
        Rect.fromCircle(
          center: Offset(borderRadius, borderRadius),
          radius: borderRadius,
        ),
        pi,
        pi / 2,
        false,
      )
      ..close();

    final fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(shapePath, fillPaint);

    final Path innerShadowPath = Path()
      ..addPath(shapePath.shift(shadowOffset), Offset.zero)
      ..addPath(shapePath, Offset.zero)
      ..fillType = PathFillType.evenOdd;

    final shadowPaint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.saveLayer(Rect.fromLTWH(0, 0, size.width, size.height), Paint());
    canvas.clipPath(shapePath);
    canvas.drawPath(innerShadowPath, shadowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
