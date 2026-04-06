import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';

class CustomSegmentedProgressBar extends StatelessWidget {
  final int totalSegments;
  final double percentComplete;
  final List<Color> gradientColors;

  const CustomSegmentedProgressBar({
    super.key,
    required this.totalSegments,
    required this.percentComplete,
    required this.gradientColors,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      height: 1.5.w,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        children: List.generate(totalSegments, (index) => Expanded(
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 1.w),
                            decoration: BoxDecoration(
                              color: (index / totalSegments) < (percentComplete / 100) ? AppColors.dashboardTeal : Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(5),
                            ),
                          ),
                        )),
                      ),
                    ),
                    // Pointer Bubble
                    Positioned(
                      left: (percentComplete / 100 * 80.w) - 5.w, // Approximate center
                      top: -10.w,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              '${percentComplete.toInt()}',
                              style: TextStyle(color: Colors.white, fontSize: 8.sp, fontWeight: FontWeight.bold),
                            ),
                          ),
                          CustomPaint(
                            size: const Size(6, 6),
                            painter: TrianglePainter(color: AppColors.primary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            );
  }
}

class TrianglePainter extends CustomPainter {
  final Color color;
  TrianglePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width / 2, size.height)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class AppTheme {
  static bool isAppThemeDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static ColorScheme getColor(BuildContext context) {
    final isDark = isAppThemeDarkMode(context);
    return ColorScheme(
      brightness: isDark ? Brightness.dark : Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: Colors.red,
      onError: Colors.white,
      surface: isDark ? AppColors.darkbackgroundPrimary : Colors.white,
      onSurface: isDark ? AppColors.darktextPrimary : AppColors.textPrimary,
      tertiary: AppColors.dashboardTeal,
      onTertiary: AppColors.textGray,
      onTertiaryContainer: AppColors.dashboardBlue,
      outline: AppColors.textGray,
      outlineVariant: AppColors.gray10,
      onSurfaceVariant: isDark ? AppColors.darktextPrimary.withOpacity(0.7) : AppColors.textSecondary,
      surfaceBright: isDark ? const Color(0xFF1E1E1E) : Colors.white,
    );
  }
}
