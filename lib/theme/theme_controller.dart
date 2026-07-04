import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton controller that holds the current ThemeMode as a
/// ValueNotifier so any widget (MaterialApp, SettingsScreen, etc.)
/// can listen and rebuild when the user toggles Dark Mode.
///
/// Requires the `shared_preferences` package:
///   flutter pub add shared_preferences
class ThemeController {
  ThemeController._internal();
  static final ThemeController instance = ThemeController._internal();

  static const _prefsKey = 'is_dark_mode';

  final ValueNotifier<ThemeMode> mode = ValueNotifier(ThemeMode.light);

  bool get isDarkMode => mode.value == ThemeMode.dark;

  /// Call once at app startup, before runApp(), so the saved
  /// preference is applied before the first frame renders.
  Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(_prefsKey) ?? false;
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
  }

  Future<void> setDarkMode(bool isDark) async {
    mode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefsKey, isDark);
  }
}