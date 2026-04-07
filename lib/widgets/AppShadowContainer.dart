import 'dart:ui';
import 'package:flutter/material.dart';

class AppShadowContainer extends StatelessWidget {
  final Widget child;

  /// 🔥 Individual radius
  final double? topLeftRadius;
  final double? topRightRadius;
  final double? bottomLeftRadius;
  final double? bottomRightRadius;

  /// fallback
  final double borderRadius;

  final Color backgroundColor;

  /// INNER SHADOW
  final bool innerTop;
  final bool innerBottom;
  final bool innerLeft;
  final bool innerRight;

  final double innerBlur;
  final Color innerColor;

  /// OUTER SHADOW
  final bool enableOuterShadow;
  final List<BoxShadow>? outerShadows;

  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final double? height;
  final double? width;
  final BoxBorder? border;

  const AppShadowContainer({
    super.key,
    required this.child,

    this.borderRadius = 12,

    /// 🔥 NEW
    this.topLeftRadius,
    this.topRightRadius,
    this.bottomLeftRadius,
    this.bottomRightRadius,

    this.backgroundColor = Colors.white,

    /// INNER
    this.innerTop = false,
    this.innerBottom = false,
    this.innerLeft = false,
    this.innerRight = false,
    this.innerBlur = 6,
    this.innerColor = const Color(0x33000000),

    /// OUTER
    this.enableOuterShadow = false,
    this.outerShadows,

    this.padding,
    this.margin,
    this.height,
    this.width,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    /// 🔥 FINAL RADIUS LOGIC
    final radius = BorderRadius.only(
      topLeft: Radius.circular(topLeftRadius ?? borderRadius),
      topRight: Radius.circular(topRightRadius ?? borderRadius),
      bottomLeft: Radius.circular(bottomLeftRadius ?? borderRadius),
      bottomRight: Radius.circular(bottomRightRadius ?? borderRadius),
    );

    return Container(
      height: height,
      width: width,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: radius,
        border: border,
        boxShadow: enableOuterShadow
            ? outerShadows ??
            [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: Offset(0, 3),
              ),
            ]
            : [],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: CustomPaint(
          painter: _InnerShadowPainter(
            borderRadius: radius,
            blur: innerBlur,
            color: innerColor,
            top: innerTop,
            bottom: innerBottom,
            left: innerLeft,
            right: innerRight,
          ),
          child: child,
        ),
      ),
    );
  }
}

class _InnerShadowPainter extends CustomPainter {
  final BorderRadius borderRadius;
  final double blur;
  final Color color;

  final bool top;
  final bool bottom;
  final bool left;
  final bool right;

  _InnerShadowPainter({
    required this.borderRadius,
    required this.blur,
    required this.color,
    required this.top,
    required this.bottom,
    required this.left,
    required this.right,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final rrect = borderRadius.toRRect(rect);

    final paint = Paint()
      ..color = color
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final outer = Path()
      ..addRect(Rect.fromLTRB(
        -size.width,
        -size.height,
        size.width * 2,
        size.height * 2,
      ));

    final inner = Path()
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;

    canvas.saveLayer(rect, Paint());

    void draw(Offset offset) {
      canvas.save();
      canvas.translate(offset.dx, offset.dy);
      canvas.drawPath(
        Path.combine(PathOperation.difference, outer, inner),
        paint,
      );
      canvas.restore();
    }

    if (top) draw(Offset(0, blur));
    if (bottom) draw(Offset(0, -blur));
    if (left) draw(Offset(blur, 0));
    if (right) draw(Offset(-blur, 0));

    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}