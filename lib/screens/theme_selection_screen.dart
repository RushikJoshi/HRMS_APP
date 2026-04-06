import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import '../utils/app_colors.dart';
import '../services/theme_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_event.dart';
import '../bloc/theme/theme_state.dart';
import '../utils/app_icons.dart';

class ThemeSelectionScreen extends StatelessWidget {
  const ThemeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Theme Selection'),
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          final currentTheme =
              themeState.currentThemeName ?? ThemeService().currentThemeName;

          return ListView(
            padding: EdgeInsets.all(2.5.w),
            children: [
              _buildThemeOption(
                context,
                'Light',
                AppIcons.lightMode,
                Colors.white,
                currentTheme,
              ),
              SizedBox(height: 3.w),
              _buildThemeOption(
                context,
                'Dark',
                AppIcons.darkMode,
                Colors.black87,
                currentTheme,
              ),
              SizedBox(height: 3.w),
              _buildThemeOption(
                context,
                'System',
                AppIcons.phoneAndroid,
                Colors.grey,
                currentTheme,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String theme,
    IconData icon,
    Color previewColor,
    String currentTheme,
  ) {
    final isSelected = currentTheme == theme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color;
    final borderColor = isSelected
        ? AppColors.primary
        : (isDark ? Colors.white12 : AppColors.gray10);

    return InkWell(
      onTap: () {
        // Dispatch to ThemeBloc so entire app updates
        try {
          context.read<ThemeBloc>().add(ThemeChangedByName(theme));
        } catch (_) {
          // Fallback to ThemeService if Bloc not available
          ThemeService().setTheme(theme);
        }
      },
      child: Container(
        padding: EdgeInsets.all(2.5.w),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isSelected ? 2 : 1),
        ),
        child: Row(
          children: [
            Container(
              width: 15.w,
              height: 15.w,
              decoration: BoxDecoration(
                color: previewColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: Icon(
                icon,
                color: theme == 'Dark' ? Colors.white : Colors.black,
              ),
            ),
            SizedBox(width: 4.w),
            Expanded(
              child: Text(
                theme,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppColors.textPrimary,
                ),
              ),
            ),
            if (isSelected)
              const Icon(AppIcons.checkCircle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}
