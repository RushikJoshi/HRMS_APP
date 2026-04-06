import 'package:flutter/material.dart';
import 'package:hrms_ess/utils/app_colors.dart';

import '../utils/responsive_utility.dart';
import 'compatibility_theming.dart';
import 'custom_text.dart';


class BorderContainerWraper extends StatelessWidget {
  final Widget child;
  final Color? borderColor;
  final Color? backgroundColor;
  final double? borderWidth;
  final double? borderRadius;
  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final bool isShadow;
  final bool isBorder;
  final bool isNotificationBadge;
  final String? notificationCount;

  const BorderContainerWraper({
    super.key,
    required this.child,
    this.borderColor,
    this.backgroundColor,
    this.borderWidth,
    this.borderRadius,
    this.height,
    this.width,
    this.padding,
    this.margin,
    this.isShadow = false,
    this.isBorder = true,
    this.isNotificationBadge = false,
    this.notificationCount,
  });

  @override
  Widget build(BuildContext context) {
    final aTheme = AppTheme.getColor(context);
    final bRadius = borderRadius ?? 8.0;

    Widget container = Container(
      height: height,
      width: width,
      padding: padding ?? const EdgeInsets.all(8.0),
      margin: margin ?? const EdgeInsets.all(0.0),
      decoration: BoxDecoration(
        color: backgroundColor ?? aTheme.surface,
        borderRadius: BorderRadius.circular(bRadius),
        border: isBorder
            ? Border.all(
                color: borderColor ?? aTheme.outlineVariant,
                width: borderWidth ?? 1.0,
              )
            : null,
        boxShadow: isShadow
            ? [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.1),
                  blurRadius: 5.0,
                  offset: const Offset(0, 2),
                ),
              ]
            : [],
      ),
      child: child,
    );

    if (isNotificationBadge) {
      return Stack(
        children: [
          container,
          Positioned(
            top: 0,
            right: 1,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: aTheme.secondary,
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(bRadius),
                  bottomLeft: Radius.circular(16 * Responsive.getResponsive(context)),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.secondary.withOpacity(0.10),
                    blurRadius: 1.26,
                    offset: const Offset(0, 0.9),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 2.0 * Responsive.getResponsive(context),
                ),
                child: CustomText(
                  notificationCount.toString(),
                  color: aTheme.surface,
                  fontSize: 10 * Responsive.getResponsiveText(context),
                  fontWeight: FontWeight.w600,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return container;
  }
}