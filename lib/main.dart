import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'theme/glass_theme.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'utils/settings_manager.dart';
import 'widgets/liquid_nav_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final SettingsManager _settingsManager = SettingsManager();
  bool _settingsLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    await _settingsManager.loadSettings();
    if (mounted) {
      setState(() {
        _settingsLoaded = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_settingsLoaded) {
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _settingsManager,
      builder: (context, child) {
        final careMode = _settingsManager.careMode;
        return MaterialApp(
          title: _getAppTitle(),
          debugShowCheckedModeBanner: false,
          theme: GlassTheme.lightThemeWithScale(careMode, _settingsManager.fontScale),
          darkTheme: GlassTheme.darkThemeWithScale(careMode, _settingsManager.fontScale),
          themeMode: _settingsManager.themeMode,
          locale: _settingsManager.locale,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const MainNavigation(),
        );
      },
    );
  }

  String _getAppTitle() {
    final locale = _settingsManager.locale;
    switch ('${locale.languageCode}${locale.countryCode != null ? '_${locale.countryCode}' : ''}') {
      case 'zh':
        return '智行苏州';
      case 'zh_TW':
        return '智行蘇州';
      case 'zh_HK':
        return '智行蘇州';
      case 'ja':
        return '蘇州スマートモビリティ';
      case 'ko':
        return '수저 스마트 모빌리티';
      default:
        return 'Suzhou Smart Mobility';
    }
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final List<Widget> _pages = const [
    HomePage(),
    SearchPage(),
    SettingsPage(),
  ];

  final List<IconData> _navIcons = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.settings_outlined,
  ];
  final List<IconData> _navActiveIcons = [
    Icons.home,
    Icons.search,
    Icons.settings,
  ];

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final localizations = AppLocalizations.of(context)!;
    final navTitles = [localizations.home, localizations.search, localizations.settings];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: LiquidNavBar(
        currentIndex: _currentIndex,
        onIndexChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        titles: navTitles,
        icons: _navIcons,
        activeIcons: _navActiveIcons,
        mode: NavBarMode.iconsOnly,
        isDarkMode: isDarkMode,
        height: 60,
      ),
    );
  }
}
