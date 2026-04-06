import 'package:equatable/equatable.dart';
import '../../models/employee.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String companyCode;
  final String employeeId;
  final String password;

  const AuthLoginRequested({
    required this.companyCode,
    required this.employeeId,
    required this.password,
  });

  @override
  List<Object?> get props => [companyCode, employeeId, password];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthUserChanged extends AuthEvent {
  final Employee? user;

  const AuthUserChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthBiometricLoginRequested extends AuthEvent {
  const AuthBiometricLoginRequested();
}

class AuthInitRequested extends AuthEvent {
  const AuthInitRequested();
}
