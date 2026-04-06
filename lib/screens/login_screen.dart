import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../utils/app_colors.dart';
import '../utils/app_icons.dart';
import '../bloc/auth/auth_bloc.dart';
import '../bloc/auth/auth_event.dart';
import '../bloc/auth/auth_state.dart';
import '../bloc/login/login_bloc.dart';
import '../bloc/login/login_event.dart';
import '../bloc/login/login_state.dart';
import 'dashboard_screen.dart';
import 'package:local_auth/local_auth.dart';
import '../services/storage_service.dart';
import '../widgets/custom_text.dart';
import '../widgets/custom_text_field_new.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider(create: (context) => LoginBloc())],
      child: const _LoginScreenContent(),
    );
  }
}

class _LoginScreenContent extends StatefulWidget {
  const _LoginScreenContent();

  @override
  State<_LoginScreenContent> createState() => _LoginScreenContentState();
}

class _LoginScreenContentState extends State<_LoginScreenContent> {
  final _formKey = GlobalKey<FormState>();
  final _companyCodeController = TextEditingController();
  final _employeeIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final LocalAuthentication auth = LocalAuthentication();
  bool _rememberMe = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAutoLogin();
  }

  Future<void> _checkBiometricAutoLogin() async {
    // Small delay to let UI render
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    final isEnabled = await StorageService.isBiometricEnabled();
    if (isEnabled) {
      _authenticate();
    }
  }

  @override
  void dispose() {
    _companyCodeController.dispose();
    _employeeIdController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateCompanyCode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Company Code is required';
    }
    if (value.trim().isEmpty) {
      return 'Company Code cannot be empty';
    }
    return null;
  }

  String? _validateEmployeeId(String? value) {
    if (value == null || value.isEmpty) {
      return 'Employee ID is required';
    }
    if (value.trim().isEmpty) {
      return 'Employee ID cannot be empty';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthLoginRequested(
          companyCode: _companyCodeController.text.trim(),
          employeeId: _employeeIdController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  Future<void> _handleBiometricLogin() async {
    final isEnabled = await StorageService.isBiometricEnabled();

    if (!isEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: CustomText(
              'Please enable Biometric Authentication in Settings first',
              isKey: false,
              color: Colors.white,
            ),
            backgroundColor: AppColors.secondary,
          ),
        );
      }
      return;
    }

    _authenticate();
  }

  Future<void> _authenticate() async {
    try {
      final bool didAuthenticate = await auth.authenticate(
        localizedReason: 'Please authenticate to login',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (didAuthenticate && mounted) {
        context.read<AuthBloc>().add(const AuthBiometricLoginRequested());
      }
    } catch (e) {
      print('Biometric Error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: CustomText(
              'Authentication failed: $e',
              isKey: false,
              color: Colors.white,
            ),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const DashboardScreen()),
          );
        } else if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: CustomText(
                state.message,
                isKey: false,
                color: Colors.white,
              ),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.loginGradientTop,
                AppColors.loginGradientBottom,
              ],
            ),
          ),
          child: SafeArea(
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 12.h),
                    // Welcome Text
                    const CustomText(
                      'Welcome Back',
                      isKey: false,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.dashboardTeal,
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8.w),
                    // Company Code Field
                    NewTextField(
                      controller: _companyCodeController,
                      hintText: 'Company Code',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: _validateCompanyCode,
                      prefix: const Icon(
                        AppIcons.businessRounded,
                        color: AppColors.loginIconGray,
                      ),
                    ),
                    SizedBox(height: 4.w),
                    // Employee ID Field
                    NewTextField(
                      controller: _employeeIdController,
                      hintText: 'Employee ID',
                      keyboardType: TextInputType.text,
                      textInputAction: TextInputAction.next,
                      validator: _validateEmployeeId,
                      prefix: const Icon(
                        AppIcons.personOutlined,
                        color: AppColors.loginIconGray,
                      ),
                    ),
                    SizedBox(height: 4.w),
                    // Password Field
                    BlocBuilder<LoginBloc, LoginState>(
                      builder: (context, loginState) {
                        return NewTextField(
                          controller: _passwordController,
                          hintText: 'Password',
                          obscureText: loginState.obscurePassword,
                          textInputAction: TextInputAction.done,
                          validator: _validatePassword,
                          prefix: const Icon(
                            Icons.lock_outline,
                            color: AppColors.loginIconGray,
                          ),
                          suffix: IconButton(
                            icon: Icon(
                              loginState.obscurePassword
                                  ? AppIcons.visibilityOffOutlined
                                  : AppIcons.visibilityOutlined,
                              color: AppColors.loginIconGray,
                              size: 5.w,
                            ),
                            onPressed: () => context.read<LoginBloc>().add(
                              const LoginTogglePasswordVisibility(),
                            ),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: 10.w),
                    // Login Button
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.dashboardTeal,
                            foregroundColor: AppColors.white,
                            padding: EdgeInsets.symmetric(vertical: 4.w),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? SizedBox(
                                  height: 5.w,
                                  width: 5.w,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 0.5.w,
                                    valueColor:
                                        const AlwaysStoppedAnimation<Color>(
                                          AppColors.white,
                                        ),
                                  ),
                                )
                              : const CustomText(
                                  'Login',
                                  isKey: false,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                        );
                      },
                    ),
                    SizedBox(height: 8.w),
                    // Remember me
                    Row(
                      children: [
                        Checkbox(
                          value: _rememberMe,
                          onChanged: (value) =>
                              setState(() => _rememberMe = value ?? false),
                          activeColor: AppColors.dashboardTeal,
                        ),
                        const CustomText(
                          'Remember me',
                          isKey: false,
                          color: AppColors.textColorGray,
                        ),
                      ],
                    ),
                    SizedBox(height: 5.w),
                    // Use Biometrics Button
                    OutlinedButton.icon(
                      onPressed: _handleBiometricLogin,
                      icon: Icon(
                        AppIcons.fingerprint,
                        color: AppColors.dashboardTeal,
                        size: 16.sp,
                      ),
                      label: const CustomText(
                        'Use Biometrics',
                        isKey: false,
                        fontWeight: FontWeight.w600,
                        color: AppColors.dashboardTeal,
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 3.5.w),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(
                          color: AppColors.dashboardTeal,
                          width: 1.2,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.w),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
