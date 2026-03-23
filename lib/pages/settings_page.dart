import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../theme/glass_theme.dart';
import '../utils/settings_manager.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsManager _settingsManager = SettingsManager();
  ThemeMode _currentThemeMode = ThemeMode.system;
  String _currentLanguage = 'en';
  bool _careMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsManager.loadSettings();
    setState(() {
      _currentThemeMode = _settingsManager.themeMode;
      _currentLanguage = _settingsManager.locale.languageCode;
      _careMode = _settingsManager.careMode;
    });
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    await _settingsManager.setThemeMode(mode);
    setState(() {
      _currentThemeMode = mode;
    });
  }

  Future<void> _changeLanguage(String language) async {
    await _settingsManager.setLocale(Locale(language));
    setState(() {
      _currentLanguage = language;
    });
  }

  Future<void> _toggleCareMode(bool value) async {
    await _settingsManager.setCareMode(value);
    setState(() {
      _careMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF0F0F1A),
                    const Color(0xFF1A1A2E),
                    const Color(0xFF16213E),
                  ]
                : [
                    const Color(0xFFF0F4F8),
                    const Color(0xFFE8EEF5),
                    const Color(0xFFD9E2EC),
                  ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(context, localizations),
              Expanded(
                child: _buildContent(context, localizations, isDark),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations localizations) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            localizations.settings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations localizations, bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildCareModeSection(context, localizations, isDark),
        const SizedBox(height: 16),
        _buildThemeSection(context, localizations, isDark),
        const SizedBox(height: 16),
        _buildLanguageSection(context, localizations, isDark),
        const SizedBox(height: 16),
        _buildAboutSection(context, localizations, isDark),
      ],
    );
  }

  Widget _buildCareModeSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return Container(
      decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.accessibility_new,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.careMode,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        localizations.careModeDescription,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey,
                            ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SwitchListTile(
            value: _careMode,
            onChanged: _toggleCareMode,
            secondary: Icon(
              _careMode ? Icons.check_circle : Icons.circle_outlined,
              color: _careMode ? Colors.orange : Colors.grey,
            ),
            title: Text(
              _careMode ? localizations.careModeEnabled : localizations.careModeDisabled,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return Container(
      decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.palette,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.theme,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          RadioListTile<ThemeMode>(
            title: Text(localizations.lightTheme),
            subtitle: Text(localizations.alwaysUseLight),
            value: ThemeMode.light,
            groupValue: _currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                _changeThemeMode(value);
              }
            },
            secondary: const Icon(Icons.light_mode, color: Colors.blue),
          ),
          RadioListTile<ThemeMode>(
            title: Text(localizations.darkTheme),
            subtitle: Text(localizations.alwaysUseDark),
            value: ThemeMode.dark,
            groupValue: _currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                _changeThemeMode(value);
              }
            },
            secondary: const Icon(Icons.dark_mode, color: Colors.blue),
          ),
          RadioListTile<ThemeMode>(
            title: Text(localizations.systemTheme),
            subtitle: Text(localizations.followSystem),
            value: ThemeMode.system,
            groupValue: _currentThemeMode,
            onChanged: (value) {
              if (value != null) {
                _changeThemeMode(value);
              }
            },
            secondary: const Icon(Icons.brightness_auto, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return Container(
      decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.language,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          RadioListTile<String>(
            title: const Text('English'),
            value: 'en',
            groupValue: _currentLanguage,
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),
          RadioListTile<String>(
            title: const Text('简体中文'),
            value: 'zh',
            groupValue: _currentLanguage,
            onChanged: (value) {
              if (value != null) {
                _changeLanguage(value);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return Container(
      decoration: isDark ? GlassTheme.glassDecorationDark : GlassTheme.glassDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.info,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  localizations.about,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ],
            ),
          ),
          ListTile(
            title: Text(localizations.appTitle),
            leading: const Icon(Icons.directions_bus, color: Colors.blue),
          ),
          ListTile(
            title: Text(localizations.version),
            subtitle: const Text('1.0.0 Beta 3 - 2026/03/23'),
            leading: const Icon(Icons.tag, color: Colors.blue),
          ),
        ],
      ),
    );
  }
}
