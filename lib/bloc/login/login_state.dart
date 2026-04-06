import 'package:equatable/equatable.dart';

class LoginState extends Equatable {
  final bool obscurePassword;

  const LoginState({this.obscurePassword = true});

  @override
  List<Object?> get props => [obscurePassword];

  LoginState copyWith({bool? obscurePassword}) {
    return LoginState(
      obscurePassword: obscurePassword ?? this.obscurePassword,
    );
  }
}

