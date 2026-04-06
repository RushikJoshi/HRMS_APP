import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;

  const ThemeState({required this.themeMode});

  String get currentThemeName {
    if (themeMode == ThemeMode.light) return 'Light';
    if (themeMode == ThemeMode.dark) return 'Dark';
    return 'System';
  }

  @override
  List<Object?> get props => [themeMode];

  ThemeState copyWith({ThemeMode? themeMode}) {
    return ThemeState(
      themeMode: themeMode ?? this.themeMode,
    );
  }
}

