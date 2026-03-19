import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/tactical_theme.dart';

/// Theme notifier that manages theme state and persistence
class ThemeNotifier extends StateNotifier<AppThemeMode> {
  ThemeNotifier() : super(AppThemeMode.solarpunk) {
    _loadTheme();
  }

  static const String _themeKey = 'app_theme_mode';

  /// Load theme preference from local storage
  Future<void> _loadTheme() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = prefs.getString(_themeKey);

      if (themeString != null) {
        final theme = themeString == 'dark'
            ? AppThemeMode.dark
            : themeString == 'solarpunk'
                ? AppThemeMode.solarpunk
                : AppThemeMode.light;
        state = theme;
        TacticalColors.setTheme(theme);
      }
    } catch (e) {
      // If loading fails, keep default light theme
      debugPrint('Error loading theme preference: $e');
    }
  }

  /// Toggle between light and dark themes
  Future<void> toggleTheme() async {
    final newTheme = state == AppThemeMode.light ? AppThemeMode.dark : AppThemeMode.light;
    await setTheme(newTheme);
  }

  /// Set specific theme
  Future<void> setTheme(AppThemeMode theme) async {
    state = theme;
    TacticalColors.setTheme(theme);

    try {
      final prefs = await SharedPreferences.getInstance();
      final themeString = theme == AppThemeMode.dark
          ? 'dark'
          : theme == AppThemeMode.solarpunk
              ? 'solarpunk'
              : 'light';
      await prefs.setString(_themeKey, themeString);
    } catch (e) {
      debugPrint('Error saving theme preference: $e');
    }
  }

  /// Get current theme as string
  String get themeString => state == AppThemeMode.dark
      ? 'dark'
      : state == AppThemeMode.solarpunk
          ? 'solarpunk'
          : 'light';

  /// Check if current theme is dark
  bool get isDark => state == AppThemeMode.dark;

  /// Check if current theme is light
  bool get isLight => state == AppThemeMode.light;

  /// Check if current theme is solarpunk
  bool get isSolarpunk => state == AppThemeMode.solarpunk;
}

/// Theme provider
final themeProvider = StateNotifierProvider<ThemeNotifier, AppThemeMode>((ref) {
  return ThemeNotifier();
});
