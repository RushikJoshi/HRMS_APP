import 'package:flutter/material.dart';
import 'package:hrms_ess/widgets/AppShadowContainer.dart';
import '../utils/responsive_utility.dart';
import 'compatibility_theming.dart';
import 'custom_myco_button.dart';
import 'custom_text.dart';

class LeaveExpandableCard extends StatefulWidget {
  final String title;
  final String? subTitle;
  final String? secondTitle;
  final bool isButton;
  final String buttonText;
  final Widget collapsedChild;
  final Widget expandedChild;
  final Widget? textChild;
  final void Function()? onTap;
  final double? headerHeight;
  final double? borderRadius;
  final EdgeInsetsGeometry? headerPadding;
  final Color? headerColor;
  final Color? borderColor;
  final bool? showHeaderPrefixIcon;
  final String? headerPrefixIcon;
  final Color? headerPrefixIconColor;
  final bool initiallyExpanded;
  final bool isText;
  final bool withInnerShadow;

  const LeaveExpandableCard({
    required this.title,
    required this.collapsedChild,
    required this.expandedChild,
    super.key,
    this.isButton = false,
    this.buttonText = '',
    this.onTap,
    this.headerHeight,
    this.borderColor,
    this.headerPadding,
    this.showHeaderPrefixIcon,
    this.headerPrefixIcon,
    this.headerPrefixIconColor,
    this.subTitle,
    this.secondTitle,
    this.borderRadius,
    this.headerColor,
    this.initiallyExpanded = false,
    this.isText = false,
    this.textChild = const SizedBox.shrink(),
    this.withInnerShadow = true,
  });

  @override
  State<LeaveExpandableCard> createState() => _LeaveExpandableCardState();
}

class _LeaveExpandableCardState extends State<LeaveExpandableCard> {
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    if (widget.initiallyExpanded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() => _expanded = true);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final radius =
        (widget.borderRadius ?? 12) * Responsive.getResponsive(context);
    final colors = AppTheme.getColor(context);

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: widget.borderColor ?? colors.outline),
        color: colors.surface,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(radius)),
            child: AppShadowContainer(
              backgroundColor:  widget.headerColor ??
            colors.secondary,
              borderRadius: 0,
              innerBottom: true,
              innerBlur: 3,
              child: Container(
                height:
                    widget.headerHeight ?? 0.068 * Responsive.getHeight(context),
                padding:
                    widget.headerPadding ??
                    EdgeInsets.all(10 * Responsive.getResponsive(context)),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(radius),
                  ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color:
                  //         widget.headerColor?.withAlpha(180) ??
                  //         colors.secondary.withAlpha(180),
                  //   ),
                  //   BoxShadow(
                  //     color: widget.headerColor ?? colors.secondary,
                  //     spreadRadius: -4.0,
                  //     blurRadius: 6.0,
                  //   ),
                  // ],
                ),
                child: Row(
                  children: [
                    if (widget.showHeaderPrefixIcon == true)
                      Image.asset(
                        widget.headerPrefixIcon ?? 'assets/images/calendar.png',
                        height: 0.1 * Responsive.getHeight(context),
                        width: 0.06 * Responsive.getWidth(context),
                        color: widget.headerPrefixIconColor,
                      ),
                    if (widget.showHeaderPrefixIcon == true)
                      SizedBox(width: 0.02 * Responsive.getWidth(context)),
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CustomText(
                            widget.title,
                            isKey: false,
                            color: colors.onPrimary,
                            fontSize: 14 * Responsive.getResponsiveText(context),
                            fontWeight: FontWeight.bold,
                          ),
                          if (widget.secondTitle != null)
                            CustomText(
                              widget.secondTitle!,
                              isKey: false,
                              color: colors.onPrimary,
                              fontSize:
                                  12 * Responsive.getResponsiveText(context),
                              fontWeight: FontWeight.w700,
                            ),
                          if (widget.subTitle != null)
                            CustomText(
                              widget.subTitle!,
                              isKey: false,
                              color: colors.onPrimary,
                              fontSize:
                                  11 * Responsive.getResponsiveText(context),
                              fontWeight: FontWeight.w600,
                            ),
                        ],
                      ),
                    ),
                    if (widget.isButton)
                      SizedBox(width: 0.02 * Responsive.getWidth(context)),
                    if (widget.isButton)
                      MyCoButton(
                        onTap: widget.onTap,
                        title: widget.buttonText,
                        textStyle: TextStyle(
                          fontSize: 12 * Responsive.getResponsiveText(context),
                          color: colors.onPrimary,
                        ),
                        width: 0.16 * Responsive.getWidth(context),
                        boarderRadius: 30 * Responsive.getResponsive(context),
                        height: 0.03 * Responsive.getHeight(context),
                        isShadowBottomLeft: true,
                      ),
                    widget.isText
                        ? widget.textChild!
                        : IconButton(
                            icon: Icon(
                              _expanded
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: colors.onPrimary,
                            ),
                            onPressed: () =>
                                setState(() => _expanded = !_expanded),
                          ),
                  ],
                ),
              ),
            ),
          ),
          widget.withInnerShadow
              ? widget.collapsedChild
              : widget.collapsedChild,
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 300),
            crossFadeState: _expanded
                ? CrossFadeState.showFirst
                : CrossFadeState.showSecond,
            firstChild: widget.expandedChild,
            secondChild: const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
