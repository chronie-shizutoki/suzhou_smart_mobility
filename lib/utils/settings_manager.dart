import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('en');

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;

  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue = prefs.getString('themeMode');
    final language = prefs.getString('language');

    if (themeModeValue != null) {
      switch (themeModeValue) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        case 'system':
        default:
          _themeMode = ThemeMode.system;
          break;
      }
    }

    if (language != null) {
      _locale = Locale(language);
    }

    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    String themeModeValue;
    switch (mode) {
      case ThemeMode.light:
        themeModeValue = 'light';
        break;
      case ThemeMode.dark:
        themeModeValue = 'dark';
        break;
      case ThemeMode.system:
      default:
        themeModeValue = 'system';
        break;
    }
    await prefs.setString('themeMode', themeModeValue);
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    notifyListeners();
  }
}
