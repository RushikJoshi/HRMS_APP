import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import 'border_container_wraper.dart';
import 'custom_text.dart';

class CommonGridSection extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String? count;
  final IconData? sectionIcon;
  final String? sectionGif;
  final List<GridItem> items;
  final Widget? headerAction;
  final bool useStandardHeader;

  const CommonGridSection({
    super.key,
    required this.title,
    this.subtitle,
    this.count,
    this.sectionIcon,
    this.sectionGif,
    required this.items,
    this.headerAction,
    this.useStandardHeader = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Standard Profile Header (Filled) or Dashboard Header (Clean with Badge)
        useStandardHeader ? _buildStandardHeader() : _buildDashboardHeader(),

        // Unified Grid of Items
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 1.w),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: items.length,
            padding: EdgeInsets.zero,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 3.w,
              mainAxisSpacing: 3.w,
              childAspectRatio: 0.82,
            ),
            itemBuilder: (context, index) {
              final item = items[index];
              return _GridCard(item: item);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildStandardHeader() {
    return Padding(
      padding: EdgeInsets.all(2.w),
      child: AppShadowContainer(
        backgroundColor:  AppColors.primary,
        borderRadius: 0,
        topRightRadius: 10,
        topLeftRadius: 10,
        innerBlur: 3,
        innerBottom: true,
        child: Container(
          padding: EdgeInsets.all(2.5.w),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                title,
                isKey: false,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              if (sectionGif != null)
                Image.asset(
                  sectionGif!,
                  height: 6.w,
                  width: 6.w,
                  errorBuilder: (c, e, s) =>
                      const Icon(Icons.star, color: Colors.white),
                )
              else if (sectionIcon != null)
                Icon(sectionIcon, color: Colors.white, size: 6.w),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDashboardHeader() {
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
                  if (count != null) ...[
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
                        count!,
                        isKey: false,
                        fontSize: 9,
                        color: AppColors.dashboardOrange,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ],
              ),
              if (subtitle != null)
                CustomText(
                  subtitle!,
                  isKey: false,
                  fontSize: 10,
                  color: Colors.grey.shade600,
                ),
            ],
          ),
          if (headerAction != null) headerAction!,
        ],
      ),
    );
  }
}

class GridItem {
  final String label;
  final IconData? icon;
  final String? iconPath;
  final VoidCallback onTap;

  GridItem({
    required this.label,
    this.icon,
    this.iconPath,
    required this.onTap,
  });
}

class _GridCard extends StatelessWidget {
  final GridItem item;

  const _GridCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: item.onTap,
      child: BorderContainerWraper(

        borderRadius: 10,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Unified circular shadow icon container
            AppShadowContainer(
              height: 11.h,
              width: 21.w,
              innerBottom: true,
              innerBlur: 4,
              border: Border.all(width: 0.9, color: Colors.grey.shade300),
              child: Center(child: _buildIcon()),
            ),
            SizedBox(height: 3.w),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 2.w),
              child: CustomText(
                item.label,
                isKey: false,
                textAlign: TextAlign.center,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    if (item.iconPath != null) {
      if (item.iconPath!.endsWith('.svg')) {
        return SvgPicture.asset(
          item.iconPath!,
          width: 12.w,
          height: 12.w,
        );
      } else {
        return Image.asset(item.iconPath!, width: 7.5.w, height: 7.5.w);
      }
    }
    return Icon(
      item.icon ?? Icons.person,
      color: AppColors.primary,
      size: 7.5.w,
    );
  }
}
