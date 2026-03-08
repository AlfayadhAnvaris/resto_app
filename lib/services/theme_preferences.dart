import 'package:shared_preferences/shared_preferences.dart';

class ThemePreferences {
  static const String _themeKey = "is_dark_theme";

  Future<void> saveTheme(bool isDark) async {
    final prefs =
        await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, isDark);
  }

  Future<bool> getTheme() async {
    final prefs =
        await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }
}