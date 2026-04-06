import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hrms_ess/screens/dashboard_screen.dart';
import 'package:hrms_ess/screens/login_screen.dart';
import 'screens/splash_screen.dart';
import 'utils/app_colors.dart';
import 'bloc/theme/theme_bloc.dart';
import 'bloc/theme/theme_event.dart';
import 'bloc/theme/theme_state.dart';
import 'bloc/auth/auth_bloc.dart';
import 'bloc/auth/auth_event.dart';
import 'bloc/auth/auth_state.dart';
import 'package:sizer/sizer.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ThemeBloc>(
          create: (context) => ThemeBloc()..add(ThemeChangedByName('System')),
        ),
        BlocProvider<AuthBloc>(create: (context) => AuthBloc()),
      ],
      child: Sizer(
        builder: (context, orientation, deviceType) {
          return BlocBuilder<ThemeBloc, ThemeState>(
            builder: (context, themeState) {
              return MaterialApp(
                title: 'HRMS ESS',
                debugShowCheckedModeBanner: false,
                theme: ThemeData(
                  colorScheme: ColorScheme.light(
                    primary: AppColors.primary,
                    secondary: AppColors.secondary,
                    surface: AppColors.bgWhite,
                    error: AppColors.error,
                    onPrimary: AppColors.white,
                    onSecondary: AppColors.white,
                    onSurface: AppColors.textPrimary,
                    onError: AppColors.white,
                  ),
                  useMaterial3: true,
                  scaffoldBackgroundColor: AppColors.backgroundPrimary,
                  textTheme: GoogleFonts.poppinsTextTheme().apply(
                    bodyColor: AppColors.textPrimary,
                    displayColor: AppColors.textPrimary,
                  ),
                  inputDecorationTheme: InputDecorationTheme(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.textfieldBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.textfieldBorder,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: AppColors.bgWhite,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  elevatedButtonTheme: ElevatedButtonThemeData(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                  ),
                  cardTheme: CardThemeData(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.gray10, width: 1),
                    ),
                    color: AppColors.bgWhite,
                  ),
                ),
                darkTheme: ThemeData(
                  colorScheme: ColorScheme.dark(
                    primary: AppColors.darkprimary,
                    secondary: AppColors.darksecondary,
                    surface: AppColors.darksurfacePrimary,
                    error: AppColors.error,
                    onPrimary: AppColors.white,
                    onSecondary: AppColors.white,
                    onSurface: AppColors.darktextPrimary,
                    onError: AppColors.white,
                  ),
                  useMaterial3: true,
                  scaffoldBackgroundColor: AppColors.darkbackgroundPrimary,
                  textTheme: GoogleFonts.poppinsTextTheme().apply(
                    bodyColor: AppColors.darktextPrimary,
                    displayColor: AppColors.darktextPrimary,
                  ),
                ),
                themeMode: themeState.themeMode,
                home: const SplashScreen(),
                routes: {
                  '/login': (context) => const LoginScreen(),
                  '/dashboard': (context) => const DashboardScreen(),
                },
              );
            },
          );
        },
      ),
    );
  }
}
