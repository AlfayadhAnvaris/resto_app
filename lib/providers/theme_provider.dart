// providers/theme_provider.dart

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themeModeKey = 'theme_mode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return false;
    }
    return _themeMode == ThemeMode.dark;
  }

  ThemeProvider() {
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final String? savedTheme = prefs.getString(_themeModeKey);

      if (savedTheme != null) {
        _themeMode = ThemeMode.values.firstWhere(
          (e) => e.name == savedTheme,
          orElse: () => ThemeMode.system,
        );
      }
    } catch (e) {
      debugPrint('Error loading theme: $e');
    }
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, _themeMode.name);
    } catch (e) {
      debugPrint('Error saving theme: $e');
    }
  }

  Future<void> toggleTheme(bool isOn) async {
    _themeMode = isOn ? ThemeMode.dark : ThemeMode.light;
    await _saveTheme();
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _saveTheme();
    notifyListeners();
  }
}