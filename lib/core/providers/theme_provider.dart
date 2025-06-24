import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_colors.dart';

enum AppTheme { light, dark, system }

class ThemeProvider extends ChangeNotifier {
  AppTheme _currentTheme = AppTheme.system;

  AppTheme get currentTheme => _currentTheme;

  bool get isLightMode {
    if (_currentTheme == AppTheme.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.light;
    }
    return _currentTheme == AppTheme.light;
  }

  Brightness get brightness {
    if (_currentTheme == AppTheme.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness;
    }
    return _currentTheme == AppTheme.light ? Brightness.light : Brightness.dark;
  }

  ThemeMode get themeMode {
    switch (_currentTheme) {
      case AppTheme.light:
        return ThemeMode.light;
      case AppTheme.dark:
        return ThemeMode.dark;
      case AppTheme.system:
        return ThemeMode.system;
    }
  }

  ThemeProvider() {
    _loadTheme();
  }

  void setTheme(AppTheme theme) async {
    _currentTheme = theme;
    _updateSystemUI();
    notifyListeners();
    await _saveTheme();
  }

  /// Updates system UI overlay style to match current theme
  void _updateSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        // Status bar
        statusBarColor: AppColors.getBG(brightness),
        statusBarIconBrightness: isLightMode
            ? Brightness.dark
            : Brightness.light,
        statusBarBrightness: isLightMode ? Brightness.light : Brightness.dark,

        // Navigation bar
        systemNavigationBarColor: AppColors.getBG(brightness),
        systemNavigationBarIconBrightness: isLightMode
            ? Brightness.dark
            : Brightness.light,
        systemNavigationBarDividerColor: AppColors.getBG(brightness),
      ),
    );
  }

  void _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final themeIndex = prefs.getInt('theme') ?? 0;
    _currentTheme = AppTheme.values[themeIndex];
    _updateSystemUI();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('theme', _currentTheme.index);
  }

  String get themeDisplayName {
    switch (_currentTheme) {
      case AppTheme.light:
        return 'Light';
      case AppTheme.dark:
        return 'Dark';
      case AppTheme.system:
        return 'System';
    }
  }
}
