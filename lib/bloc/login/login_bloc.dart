import 'package:flutter_bloc/flutter_bloc.dart';
import 'login_event.dart';
import 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  LoginBloc() : super(const LoginState()) {
    on<LoginTogglePasswordVisibility>(_onTogglePasswordVisibility);
  }

  void _onTogglePasswordVisibility(
    LoginTogglePasswordVisibility event,
    Emitter<LoginState> emit,
  ) {
    emit(state.copyWith(obscurePassword: !state.obscurePassword));
  }
}

