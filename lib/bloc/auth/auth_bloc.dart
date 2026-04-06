import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../models/employee.dart';
import '../../models/user_role.dart';
import '../../services/user_context.dart';
import '../../api/api.dart';
import '../../services/storage_service.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final UserContext _userContext;
  final Api _apiService;
  StreamSubscription<Employee?>? _userSubscription;

  AuthBloc({UserContext? userContext, Api? apiService})
    : _userContext = userContext ?? UserContext(),
      _apiService = apiService ?? Api(),
      super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthBiometricLoginRequested>(_onBiometricLoginRequested);
    on<AuthUserChanged>(_onUserChanged);
    on<AuthInitRequested>(_onAuthInitRequested);

    // Trigger initialization
    add(const AuthInitRequested());
  }

  Future<void> _onAuthInitRequested(
    AuthInitRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      // Check if there's a stored token/session
      final token = await StorageService.getToken();

      if (token != null && token.isNotEmpty) {
        // Try to refresh/verify the session
        try {
          final response = await _apiService.refreshToken();
          if (response.success && response.data != null) {
            final profile = response.data!;
            final storedEmployeeId = await StorageService.getEmployeeId();
            final storedCompanyCode = await StorageService.getCompanyCode();

            final user = Employee(
              id: profile.id ?? storedEmployeeId ?? 'unknown',
              name: profile.fullName.isNotEmpty
                  ? profile.fullName
                  : (profile.name ?? 'Employee'),
              designation: profile.designation ?? profile.role ?? 'Employee',
              email: profile.email,
              employeeId: profile.employeeId ?? storedEmployeeId ?? 'unknown',
              companyCode:
                  profile.companyCode ?? storedCompanyCode ?? 'unknown',
              department: profile.department,
              role: UserRole.employee,
              hasTeam: false,
            );

            _userContext.login(user);
            emit(AuthAuthenticated(user));
            return;
          }
        } catch (e) {
          print('AuthBloc: Token refresh failed: $e');
          await StorageService.clearSession();
        }
      }

      // No valid session, show login
      emit(const AuthUnauthenticated());
    } catch (e) {
      print('AuthBloc: Init error: $e');
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      // Call API
      final response = await _apiService.loginEmployee(
        companyCode: event.companyCode,
        employeeId: event.employeeId,
        password: event.password,
      );

      // Check if login was successful and token exists
      if (response.success &&
          response.data != null &&
          response.data!.token != null &&
          response.data!.token!.isNotEmpty) {
        // SAVE TOKEN AND CREDENTIALS
        final token = response.data!.token!;
        await StorageService.saveToken(token);
        await StorageService.saveEmployeeId(event.employeeId);
        await StorageService.saveCompanyCode(event.companyCode);
        print(
          'AuthBloc: Token saved successfully: ${token.substring(0, 10)}...',
        );

        // Create Employee object from login response data
        final employeeData = response.data!.employee;
        final user = Employee(
          id: employeeData?.id ?? event.employeeId,
          name: employeeData?.name ?? 'Employee',
          designation: employeeData?.designation ?? 'Employee',
          email: employeeData?.email,
          employeeId: employeeData?.employeeId ?? event.employeeId,
          companyCode: employeeData?.companyCode ?? event.companyCode,
          department: employeeData?.department,
          role: UserRole.employee,
          hasTeam: false,
        );

        // Update Global Context
        _userContext.login(user);
        emit(AuthAuthenticated(user));
      } else {
        // More detailed error message
        String errorMsg = response.message ?? 'Login failed. Please try again.';
        if (!response.success) {
          errorMsg =
              response.message ??
              'Invalid credentials. Please check your Company Code, Employee ID, and Password.';
        } else if (response.data == null) {
          errorMsg = 'Invalid response from server. Please try again.';
        } else if (response.data!.token == null ||
            response.data!.token!.isEmpty) {
          errorMsg =
              'Login successful but token not received. Please try again.';
        }
        emit(AuthError(errorMsg));
      }
    } catch (e) {
      // Extract clean error message
      String errorMessage = 'Login failed. Please try again.';

      if (e.toString().contains('Exception:')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else if (e.toString().isNotEmpty) {
        errorMessage = e.toString();
      }

      // Remove "Exception: " prefix if present
      if (errorMessage.startsWith('Exception: ')) {
        errorMessage = errorMessage.substring(11);
      }

      print('Login Error: $errorMessage');
      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onBiometricLoginRequested(
    AuthBiometricLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());

    try {
      final token = await StorageService.getToken();

      if (token == null || token.isEmpty) {
        print('AuthBloc: No token found for biometric login');
        emit(
          const AuthError(
            'No stored session found. Please login with password first.',
          ),
        );
        return;
      }
      print(
        'AuthBloc: Attempting Biometric Login (Verification via Profile) with token: ${token.substring(0, 10)}...',
      );

      // Requirement 8: Reset Token API / Validation
      // We use getEmployeeProfile (via refreshToken) to validate.
      // Since we just fetched it, we can use the data directly!
      final response = await _apiService.refreshToken();

      if (response.success && response.data != null) {
        final profile = response.data!;

        // Requirement: Call Notification API as well and print response
        // REMOVED to prevent duplicate API calls as CircularBloc handles this.
        /*
        try {
            print('AuthBloc: Fetching Notifications as per requirement...');
            final notifResponse = await _apiService.getNotifications();
            print('AuthBloc: Notifications Response: $notifResponse');
        } catch (e) {
            print('AuthBloc: Error fetching notifications (non-critical): $e');
        } 
        */

        // recover other IDs if missing from profile
        final storedEmployeeId = await StorageService.getEmployeeId();
        final storedCompanyCode = await StorageService.getCompanyCode();

        final user = Employee(
          id: profile.id ?? storedEmployeeId ?? 'unknown',
          name: profile.fullName.isNotEmpty
              ? profile.fullName
              : (profile.name ?? 'Employee'),
          designation: profile.designation ?? profile.role ?? 'Employee',
          email: profile.email,
          employeeId: profile.employeeId ?? storedEmployeeId ?? 'unknown',
          companyCode: profile.companyCode ?? storedCompanyCode ?? 'unknown',
          department: profile.department,
          role: UserRole
              .employee, // Defaulting to employee as role mapping might be complex
          hasTeam: false,
        );

        // Update Global Context
        _userContext.login(user);
        emit(AuthAuthenticated(user));
      } else {
        emit(
          AuthError(response.message ?? 'Session expired. Please login again.'),
        );
      }
    } catch (e) {
      String errorMessage =
          'Biometric login failed. Please login with password.';
      print('Biometric Login Error: $e');

      print('Biometric Login Error: $e');

      if (e.toString().contains('Authentication failed') ||
          e.toString().contains('401')) {
        errorMessage = 'Session expired. Please login with password.';
        // Force clear session to prevent loop
        await StorageService.clearSession();
        // Force unauthenticated state to navigate to login
        emit(const AuthUnauthenticated());
        return;
      }

      emit(AuthError(errorMessage));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Check if biometric is enabled
    final biometricEnabled = await StorageService.isBiometricEnabled();

    // Clear stored data but keep token if biometric is enabled
    await StorageService.clearSession(keepToken: biometricEnabled);

    _userContext.logout();
    emit(const AuthUnauthenticated());
  }

  void _onUserChanged(AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      emit(AuthAuthenticated(event.user!));
    } else {
      emit(const AuthUnauthenticated());
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    return super.close();
  }
}
