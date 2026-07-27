import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'zh_converter.dart';

class SettingsManager extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('zh');
  bool _careMode = false;
  double _fontScale = 1.4; // Default scale applied in care mode

  ThemeMode get themeMode => _themeMode;
  Locale get locale => _locale;
  bool get careMode => _careMode;
  double get fontScale => _fontScale;

  static final SettingsManager _instance = SettingsManager._internal();
  factory SettingsManager() => _instance;
  SettingsManager._internal();

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeValue = prefs.getString('themeMode');
    final language = prefs.getString('language');
    final countryCode = prefs.getString('languageCountryCode');
    final careModeValue = prefs.getBool('careMode');
    final fontScaleValue = prefs.getDouble('fontScale');

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
      if (countryCode != null) {
        _locale = Locale(language, countryCode);
      } else {
        _locale = Locale(language);
      }
    }

    if (careModeValue != null) {
      _careMode = careModeValue;
    }

    if (fontScaleValue != null) {
      _fontScale = fontScaleValue.clamp(1.0, 2.5);
    }

    // Sync the active locale with the converter used for name conversion.
    ZhConverter.setLocale(_locale);

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
    // Keep the converter in sync so station/route names convert immediately.
    ZhConverter.setLocale(locale);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('language', locale.languageCode);
    if (locale.countryCode != null) {
      await prefs.setString('languageCountryCode', locale.countryCode!);
    } else {
      await prefs.remove('languageCountryCode');
    }
    notifyListeners();
  }

  Future<void> setCareMode(bool enabled) async {
    _careMode = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('careMode', enabled);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale.clamp(1.0, 2.5);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('fontScale', _fontScale);
    notifyListeners();
  }
}
