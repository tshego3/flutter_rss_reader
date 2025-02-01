import 'package:flutter/material.dart';

class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool _useSystemTheme = true;

  bool get isDarkMode => _isDarkMode;
  bool get useSystemTheme => _useSystemTheme;

  void setDarkMode(bool value) {
    _isDarkMode = value;
    _useSystemTheme = false; // Disable system theme if manually set
    notifyListeners();
  }

  void setUseSystemTheme(bool value) {
    _useSystemTheme = value;
    notifyListeners();
  }

  ThemeMode get currentTheme {
    if (_useSystemTheme) {
      return ThemeMode.system;
    } else {
      return _isDarkMode ? ThemeMode.dark : ThemeMode.light;
    }
  }
}
