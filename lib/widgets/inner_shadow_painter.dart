import 'dart:ui';
import 'package:flutter/material.dart';

class InnerShadowPainter extends CustomPainter {
  final Color shadowColor;
  final double blur;
  final Offset offset;
  final double borderRadius;

  final bool top;
  final bool right;
  final bool bottom;
  final bool left;

  InnerShadowPainter({
    required this.shadowColor,
    required this.blur,
    required this.offset,
    required this.borderRadius,
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    final rrect = RRect.fromRectAndRadius(
      rect,
      Radius.circular(borderRadius),
    );

    final paint = Paint()
      ..color = shadowColor
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur);

    final outer = Path()
      ..addRect(Rect.fromLTRB(
        -size.width,
        -size.height,
        size.width * 2,
        size.height * 2,
      ));

    final inner = Path()
      ..addRRect(rrect);

    canvas.saveLayer(rect, Paint());

    final shadowPaint = Paint()
      ..blendMode = BlendMode.srcATop
      ..colorFilter = ColorFilter.mode(shadowColor, BlendMode.srcOut)
      ..imageFilter = ImageFilter.blur(sigmaX: blur, sigmaY: blur);

    canvas.saveLayer(rect.inflate(blur), shadowPaint);

    void draw(Offset shift) {
      canvas.save();
      canvas.translate(shift.dx, shift.dy);
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
    canvas.restore();
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}