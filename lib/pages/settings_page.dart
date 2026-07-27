import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../utils/settings_manager.dart';
import '../widgets/glass_container.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final SettingsManager _settingsManager = SettingsManager();
  ThemeMode _currentThemeMode = ThemeMode.system;
  String _currentLanguage = 'zh';
  String? _currentCountryCode;
  bool _careMode = false;
  double _fontScale = 1.4;

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
      _currentCountryCode = _settingsManager.locale.countryCode;
      _careMode = _settingsManager.careMode;
      _fontScale = _settingsManager.fontScale;
    });
  }

  Future<void> _changeThemeMode(ThemeMode mode) async {
    await _settingsManager.setThemeMode(mode);
    setState(() {
      _currentThemeMode = mode;
    });
  }

  Future<void> _changeLanguage(String language, {String? countryCode}) async {
    await _settingsManager.setLocale(Locale(language, countryCode));
    setState(() {
      _currentLanguage = language;
      _currentCountryCode = countryCode;
    });
  }

  Future<void> _toggleCareMode(bool value) async {
    await _settingsManager.setCareMode(value);
    setState(() {
      _careMode = value;
    });
  }

  Future<void> _changeFontScale(double value) async {
    await _settingsManager.setFontScale(value);
    setState(() {
      _fontScale = value;
    });
  }

  String get _languageValue {
    if (_currentLanguage == 'zh' && _currentCountryCode == 'TW') {
      return 'zh_TW';
    }
    if (_currentLanguage == 'zh' && _currentCountryCode == 'HK') {
      return 'zh_HK';
    }
    return _currentLanguage;
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
      // Bottom padding to avoid overlapping with floating navigation bar
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
      children: [
        _buildCareModeSection(context, localizations, isDark),
        // Font-size slider is only relevant when care mode is enabled.
        if (_careMode) ...[
          const SizedBox(height: 16),
          _buildFontScaleSection(context, localizations, isDark),
        ],
        const SizedBox(height: 16),
        _buildThemeSection(context, localizations, isDark),
        const SizedBox(height: 16),
        _buildLanguageSection(context, localizations, isDark),
        const SizedBox(height: 16),
        _buildAboutSection(context, localizations, isDark),
      ],
    );
  }

  Widget _buildSectionIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: color),
    );
  }

  Widget _buildCareModeSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _buildSectionIcon(Icons.accessibility_new, Colors.orange),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  localizations.careMode,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  localizations.careModeDescription,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurface
                            .withValues(alpha: 0.6),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Switch(
            value: _careMode,
            activeThumbColor: Colors.orange,
            onChanged: _toggleCareMode,
          ),
        ],
      ),
    );
  }

  Widget _buildFontScaleSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.format_size, Colors.orange),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.fontScale,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${(_fontScale * 100).round()}%',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider(
            value: _fontScale,
            min: 1.0,
            max: 2.0,
            divisions: 10,
            label: '${(_fontScale * 100).round()}%',
            activeColor: Colors.orange,
            onChanged: _changeFontScale,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.palette, Colors.blue),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.theme,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _buildThemeDropdown(context, localizations, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeDropdown(BuildContext context, AppLocalizations localizations, bool isDark) {
    return _buildDropdownShell(
      isDark: isDark,
      child: DropdownButton<ThemeMode>(
        value: _currentThemeMode,
        isDense: true,
        borderRadius: BorderRadius.circular(16),
        dropdownColor: isDark
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(
            value: ThemeMode.light,
            child: _buildDropdownItem(Icons.light_mode, localizations.lightTheme),
          ),
          DropdownMenuItem(
            value: ThemeMode.dark,
            child: _buildDropdownItem(Icons.dark_mode, localizations.darkTheme),
          ),
          DropdownMenuItem(
            value: ThemeMode.system,
            child: _buildDropdownItem(Icons.brightness_auto, localizations.systemTheme),
          ),
        ],
        onChanged: (value) {
          if (value != null) {
            _changeThemeMode(value);
          }
        },
      ),
    );
  }

  Widget _buildLanguageSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.language, Colors.teal),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  localizations.language,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: _buildLanguageDropdown(context, localizations, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageDropdown(BuildContext context, AppLocalizations localizations, bool isDark) {
    // Native (local) names, shown next to the translated label so users
    // can recognise each language even when the UI is in another tongue.
    const nativeNames = <String, String>{
      'zh': '简体中文',
      'zh_TW': '繁體中文',
      'zh_HK': '繁體中文（香港）',
      'en': 'English',
      'ja': '日本語',
      'ko': '한국어',
    };
    // Translated labels in the current UI language.
    final translatedNames = <String, String>{
      'zh': localizations.chineseSimplified,
      'zh_TW': localizations.chineseTraditional,
      'zh_HK': localizations.chineseHongKong,
      'en': localizations.english,
      'ja': localizations.japanese,
      'ko': localizations.korean,
    };
    // The user's current language value (e.g. 'zh', 'zh_TW').
    final currentValue = _languageValue;

    // Show the native name, plus the translated name in parentheses
    // when it differs from the UI language.
    Text labelFor(String value) {
      final native = nativeNames[value]!;
      final translated = translatedNames[value]!;
      if (value == currentValue || native == translated) {
        return Text(native);
      }
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(text: native),
            TextSpan(
              text: ' ($translated)',
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      );
    }

    return _buildDropdownShell(
      isDark: isDark,
      child: DropdownButton<String>(
        value: _languageValue,
        isDense: true,
        borderRadius: BorderRadius.circular(16),
        dropdownColor: isDark
            ? const Color(0xFF1A1A2E).withValues(alpha: 0.96)
            : Colors.white.withValues(alpha: 0.96),
        icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.blue),
        underline: const SizedBox.shrink(),
        items: [
          DropdownMenuItem(value: 'zh', child: labelFor('zh')),
          DropdownMenuItem(value: 'zh_TW', child: labelFor('zh_TW')),
          DropdownMenuItem(value: 'zh_HK', child: labelFor('zh_HK')),
          DropdownMenuItem(value: 'en', child: labelFor('en')),
          DropdownMenuItem(value: 'ja', child: labelFor('ja')),
          DropdownMenuItem(value: 'ko', child: labelFor('ko')),
        ],
        onChanged: (value) {
          if (value == null) return;
          if (value == 'zh_TW') {
            _changeLanguage('zh', countryCode: 'TW');
          } else if (value == 'zh_HK') {
            _changeLanguage('zh', countryCode: 'HK');
          } else {
            _changeLanguage(value);
          }
        },
      ),
    );
  }

  /// Glass shell for dropdown buttons
  Widget _buildDropdownShell({required bool isDark, required Widget child}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.7),
        ),
      ),
      child: DropdownButtonHideUnderline(child: child),
    );
  }

  Widget _buildDropdownItem(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.blue),
        const SizedBox(width: 8),
        Text(label),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context, AppLocalizations localizations, bool isDark) {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _buildSectionIcon(Icons.info, Colors.indigo),
              const SizedBox(width: 12),
              Text(
                localizations.about,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.directions_bus, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Text(
                localizations.appTitle,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.tag, color: Colors.blue, size: 20),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.version,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    '${localizations.appTitle} 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
