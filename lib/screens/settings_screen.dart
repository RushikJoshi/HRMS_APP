import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:local_auth/local_auth.dart';
import '../utils/app_colors.dart';
import 'theme_selection_screen.dart';
import 'face_registration_screen.dart';
import '../widgets/logout_confirmation_dialog.dart';
import '../services/theme_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/theme/theme_bloc.dart';
import '../bloc/theme/theme_state.dart';
import '../services/storage_service.dart';
import '../utils/app_icons.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalAuthentication auth = LocalAuthentication();
  bool _isBiometricEnabled = false;
  bool _canCheckBiometrics = false;

  @override
  void initState() {
    super.initState();
    _checkBiometrics();
    _loadBiometricSettings();
  }

  Future<void> _checkBiometrics() async {
    try {
      final canCheck = await auth.canCheckBiometrics;
      final isDeviceSupported = await auth.isDeviceSupported();
      setState(() {
        _canCheckBiometrics = canCheck && isDeviceSupported;
      });
    } catch (e) {
      print('Error checking biometrics: $e');
    }
  }

  Future<void> _loadBiometricSettings() async {
    final enabled = await StorageService.isBiometricEnabled();
    setState(() {
      _isBiometricEnabled = enabled;
    });
  }

  Future<void> _toggleBiometric(bool value) async {
    await StorageService.saveBiometricEnabled(value);
    setState(() {
      _isBiometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Theme.of(context).cardTheme.color,
        elevation: 0,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, themeState) {
          return ListView(
            padding: EdgeInsets.all(2.5.w),
            children: [
              _buildSectionTitle('Appearance'),
              _buildSettingsTile(
                context,
                icon: AppIcons.brightness,
                title: 'Theme',
                subtitle: themeState.currentThemeName,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ThemeSelectionScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.w),
              _buildSectionTitle('Security'),
              if (_canCheckBiometrics)
                _buildSettingsTile(
                  context,
                  icon: AppIcons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: _isBiometricEnabled ? 'Enabled' : 'Disabled',
                  trailing: Switch(
                    value: _isBiometricEnabled,
                    onChanged: (value) => _toggleBiometric(value),
                    activeColor: AppColors.primary,
                  ),
                  onTap: () => _toggleBiometric(!_isBiometricEnabled),
                )
              else
                _buildSettingsTile(
                  context,
                  icon: AppIcons.fingerprint,
                  title: 'Biometric Authentication',
                  subtitle: 'Not supported on this device',
                  onTap: null,
                ),
              _buildSettingsTile(
                context,
                icon: AppIcons.face,
                title: 'Face Registration',
                subtitle: 'Register or update your face data',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const FaceRegistrationScreen(),
                    ),
                  );
                },
              ),
              SizedBox(height: 4.w),
              _buildSectionTitle('Account'),
              _buildSettingsTile(
                context,
                icon: AppIcons.logout,
                title: 'Logout',
                titleColor: AppColors.error,
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (context) => const LogoutConfirmationDialog(),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: EdgeInsets.all(2.5.w),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11.sp,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    Color? titleColor,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    // Determine colors based on Theme
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = Theme.of(context).cardTheme.color;
    final borderColor = isDark ? Colors.white12 : AppColors.gray10;

    return Container(
      margin: EdgeInsets.only(bottom: 2.w),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: ListTile(
        leading: Container(
          padding: EdgeInsets.all(2.w),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppColors.primary),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: titleColor ?? Theme.of(context).colorScheme.onSurface,
          ),
        ),
        subtitle: subtitle != null
            ? Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10.sp,
                  color: isDark
                      ? Colors.grey.shade400
                      : AppColors.textSecondary,
                ),
              )
            : null,
        trailing:
            trailing ??
            (onTap != null
                ? Icon(
                    AppIcons.chevronRightRounded,
                    color: isDark
                        ? Colors.grey.shade400
                        : AppColors.textSecondary,
                  )
                : null),
        onTap: onTap,
      ),
    );
  }
}
