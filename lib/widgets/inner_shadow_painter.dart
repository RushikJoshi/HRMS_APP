import 'dart:ui';
import 'package:flutter/material.dart';

class InnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double blur;
  final double spread;
  final Offset offset;
  final BorderRadius borderRadius;

  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  InnerShadowPainter({
    required this.shadowColor,
    required this.blur,
    required this.spread,
    required this.offset,
    required this.borderRadius,
    this.top = false,
    this.right = false,
    this.bottom = false,
    this.left = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    /// ❌ Nothing selected → no shadow
    if (!top && !right && !bottom && !left) return;

    final rect = Offset.zero & size;
    final rrect = borderRadius.toRRect(rect);

    final paint = Paint()
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    canvas.saveLayer(rect, Paint());

    /// TOP
    if (top) {
      paint.shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [shadowColor, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, size.width, spread));

      canvas.drawRect(
        Rect.fromLTWH(0, 0, size.width, spread),
        paint,
      );
    }

    /// BOTTOM
    if (bottom) {
      paint.shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [shadowColor, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, size.height - spread, size.width, spread));

      canvas.drawRect(
        Rect.fromLTWH(0, size.height - spread, size.width, spread),
        paint,
      );
    }

    /// LEFT
    if (left) {
      paint.shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        colors: [shadowColor, Colors.transparent],
      ).createShader(Rect.fromLTWH(0, 0, spread, size.height));

      canvas.drawRect(
        Rect.fromLTWH(0, 0, spread, size.height),
        paint,
      );
    }

    /// RIGHT
    if (right) {
      paint.shader = LinearGradient(
        begin: Alignment.centerRight,
        end: Alignment.centerLeft,
        colors: [shadowColor, Colors.transparent],
      ).createShader(Rect.fromLTWH(size.width - spread, 0, spread, size.height));

      canvas.drawRect(
        Rect.fromLTWH(size.width - spread, 0, spread, size.height),
        paint,
      );
    }

    /// Keep inside rounded shape
    final clipPath = Path()..addRRect(rrect);
    canvas.drawPath(clipPath, Paint()..blendMode = BlendMode.dstIn);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant InnerShadowPainter oldDelegate) => true;
}