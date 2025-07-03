import 'package:flutter/material.dart';
import '../services/preferences_service.dart';
import '../utils/app_constants.dart';

class ThemeProvider extends ChangeNotifier {
  final PreferencesService _prefs = PreferencesService.instance;
  
  ThemeMode _themeMode = ThemeMode.system;
  
  ThemeProvider() {
    _loadThemeMode();
  }
  
  ThemeMode get themeMode => _themeMode;
  
  String get themeModeString {
    switch (_themeMode) {
      case ThemeMode.light:
        return AppConstants.themeLight;
      case ThemeMode.dark:
        return AppConstants.themeDark;
      case ThemeMode.system:
        return AppConstants.themeSystem;
    }
  }
  
  bool get isDarkMode {
    return _themeMode == ThemeMode.dark;
  }
  
  bool get isLightMode {
    return _themeMode == ThemeMode.light;
  }
  
  bool get isSystemMode {
    return _themeMode == ThemeMode.system;
  }
  
  void _loadThemeMode() {
    final savedThemeMode = _prefs.themeMode;
    switch (savedThemeMode) {
      case AppConstants.themeLight:
        _themeMode = ThemeMode.light;
        break;
      case AppConstants.themeDark:
        _themeMode = ThemeMode.dark;
        break;
      case AppConstants.themeSystem:
      default:
        _themeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }
  
  Future<void> setThemeMode(ThemeMode mode) async {
    if (_themeMode == mode) return;
    
    _themeMode = mode;
    
    String modeString;
    switch (mode) {
      case ThemeMode.light:
        modeString = AppConstants.themeLight;
        break;
      case ThemeMode.dark:
        modeString = AppConstants.themeDark;
        break;
      case ThemeMode.system:
        modeString = AppConstants.themeSystem;
        break;
    }
    
    await _prefs.setThemeMode(modeString);
    notifyListeners();
  }
  
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }
  
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }
  
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }
  
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkTheme();
    } else {
      await setLightTheme();
    }
  }
}