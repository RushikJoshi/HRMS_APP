
import 'package:flutter/material.dart';

class ThemeService extends ChangeNotifier {
  static final ThemeService _instance = ThemeService._internal();

  factory ThemeService() {
    return _instance;
  }

  ThemeService._internal();

  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      _themeMode = mode;
      notifyListeners();
    }
  }

  // Helper to convert string to ThemeMode
  void setTheme(String theme) {
    switch (theme) {
      case 'Light':
        setThemeMode(ThemeMode.light);
        break;
      case 'Dark':
        setThemeMode(ThemeMode.dark);
        break;
      case 'System':
        setThemeMode(ThemeMode.system);
        break;
    }
  }

  String get currentThemeName {
    if (_themeMode == ThemeMode.light) return 'Light';
    if (_themeMode == ThemeMode.dark) return 'Dark';
    return 'System';
  }
}
