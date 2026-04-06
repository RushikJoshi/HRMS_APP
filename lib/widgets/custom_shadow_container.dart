import 'package:flutter/material.dart';

import '../utils/responsive_utility.dart';
import 'compatibility_theming.dart';
import 'custom_text.dart';

class CustomShadowContainer extends StatelessWidget {
  final Widget image;
  final String? title;
  final bool? isRect;
  final double? height, width, boxPadding, imagePadding, imgTitleSpacing;

  const CustomShadowContainer({
    required this.image,
    super.key,
    this.title,
    this.isRect,
    this.height,
    this.width,
    this.boxPadding,
    this.imagePadding,
    this.imgTitleSpacing,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    width: width ?? double.infinity,
    height: height,
    child: Column(
      mainAxisAlignment: imgTitleSpacing != null
          ? MainAxisAlignment.center
          : MainAxisAlignment.spaceEvenly,
      mainAxisSize: MainAxisSize.min,
      spacing: imgTitleSpacing ?? 0,
      children: [
        Padding(
          padding: EdgeInsets.only(
            top: boxPadding ?? 14,
            right: boxPadding ?? 14,
            left: boxPadding ?? 14,
          ),
          child: Container(
            padding: EdgeInsets.all(imagePadding ?? 15),
            decoration: BoxDecoration(
              color: AppTheme.getColor(context).surface,
              borderRadius: BorderRadius.circular(isRect == true ? 12 : 100),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(child: image),
          ),
        ),

        CustomText(
          title ?? '',
          textAlign: TextAlign.center,
          fontSize: 12 * Responsive.getDashboardResponsiveText(context),
          fontWeight: FontWeight.w600,
        ),
      ],
    ),
  );
}
