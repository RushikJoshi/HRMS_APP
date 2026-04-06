import 'package:flutter/material.dart';
import 'inner_shadow_painter.dart';

class AppInnerShadow extends StatelessWidget {
  final Widget? child;

  final double borderRadius;
  final double? shadowRadius;

  final double blur;
  final double spread;
  final Offset offset;

  final Color backgroundColor;
  final Color shadowColor;

  /// TRUE directional control (NOT diagonal)
  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  final double? height;
  final double? width;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final BoxBorder? border;
  final BoxShape shape;

  const AppInnerShadow({
    super.key,
    this.child,
    this.borderRadius = 20,
    this.shadowRadius,
    this.blur = 10,
    this.spread = 6,
    this.offset = Offset.zero,
    this.backgroundColor = Colors.white,
    this.shadowColor = const Color(0x33000000),

    /// DEFAULT = NO SHADOW
    this.top = false,
    this.right = false,
    this.bottom = false,
    this.left = false,

    this.height,
    this.width,
    this.padding,
    this.margin,
    this.border,
    this.shape = BoxShape.rectangle,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius radius =
    shape == BoxShape.circle
        ? BorderRadius.circular(1000)
        : BorderRadius.circular(borderRadius);

    final BorderRadius shadowRad =
    BorderRadius.circular(shadowRadius ?? borderRadius);

    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: shape == BoxShape.circle ? null : radius,
        shape: shape,
        border: border,
      ),

      /// 🔥 FULL CLIP FIX
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: InnerShadowPainter(
            shadowColor: shadowColor,
            blur: blur,
            spread: spread,
            offset: offset,
            borderRadius: shadowRad,

            top: top,
            right: right,
            bottom: bottom,
            left: left,
          ),
          child: child ?? const SizedBox(),
        ),
      ),
    );
  }
}