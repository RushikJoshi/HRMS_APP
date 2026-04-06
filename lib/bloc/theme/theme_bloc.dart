import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import '../../services/theme_service.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  final ThemeService _themeService;

  ThemeBloc({ThemeService? themeService})
      : _themeService = themeService ?? ThemeService(),
        super(ThemeState(themeMode: ThemeService().themeMode)) {
    on<ThemeChanged>(_onThemeChanged);
    on<ThemeChangedByName>(_onThemeChangedByName);
  }

  void _onThemeChanged(
    ThemeChanged event,
    Emitter<ThemeState> emit,
  ) {
    _themeService.setThemeMode(event.themeMode);
    emit(state.copyWith(themeMode: event.themeMode));
  }

  void _onThemeChangedByName(
    ThemeChangedByName event,
    Emitter<ThemeState> emit,
  ) {
    _themeService.setTheme(event.themeName);
    final themeMode = _themeService.themeMode;
    emit(state.copyWith(themeMode: themeMode));
  }
}

