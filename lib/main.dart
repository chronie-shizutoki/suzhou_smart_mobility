import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'theme/glass_theme.dart';
import 'pages/home_page.dart';
import 'pages/search_page.dart';
import 'pages/settings_page.dart';
import 'utils/settings_manager.dart';
import 'utils/responsive.dart';
import 'widgets/liquid_nav_bar.dart';
import 'widgets/top_navigation_bar.dart';
import 'widgets/station_detail_pane.dart';
import 'models/station.dart';

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

  // Selected station for the right pane of the wide-screen two-column layout.
  Station? _selectedHomeStation;
  Station? _selectedSearchStation;

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

    // Adaptive layout: phones keep the floating bottom navigation, while
    // large screens get a top navigation bar (with text) and a two-pane
    // master/detail view.
    if (isWideLayout(context)) {
      return _buildWideLayout(context, localizations, isDarkMode, navTitles);
    }
    return _buildNarrowLayout(context, localizations, isDarkMode, navTitles);
  }

  Widget _buildNarrowLayout(
    BuildContext context,
    AppLocalizations localizations,
    bool isDarkMode,
    List<String> navTitles,
  ) {
    const pages = [
      HomePage(),
      SearchPage(),
      SettingsPage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: pages,
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

  Widget _buildWideLayout(
    BuildContext context,
    AppLocalizations localizations,
    bool isDarkMode,
    List<String> navTitles,
  ) {
    final isDark = isDarkMode;
    final decoration = isDark
        ? GlassTheme.glassDecorationDark
        : GlassTheme.glassDecoration;

    final homePane = Row(
      children: [
        Expanded(
          flex: 4,
          child: HomePage(
            showSearch: true,
            selectedStation: _selectedHomeStation,
            onStationSelected: (station) {
              setState(() {
                _selectedHomeStation = station;
              });
            },
          ),
        ),
        Container(width: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
        Expanded(
          flex: 6,
          child: Container(
            decoration: decoration,
            margin: const EdgeInsets.all(16),
            child: _selectedHomeStation != null
                ? StationDetailPane(
                    key: ValueKey(_selectedHomeStation!.stationId),
                    station: _selectedHomeStation!,
                  )
                : _buildDetailPlaceholder(context, localizations),
          ),
        ),
      ],
    );

    final searchPane = Row(
      children: [
        Expanded(
          flex: 4,
          child: SearchPage(
            onStationSelected: (station) {
              setState(() {
                _selectedSearchStation = station;
              });
            },
          ),
        ),
        Container(width: 1, color: Theme.of(context).dividerColor.withValues(alpha: 0.4)),
        Expanded(
          flex: 6,
          child: Container(
            decoration: decoration,
            margin: const EdgeInsets.all(16),
            child: _selectedSearchStation != null
                ? StationDetailPane(
                    key: ValueKey(_selectedSearchStation!.stationId),
                    station: _selectedSearchStation!,
                  )
                : _buildDetailPlaceholder(context, localizations),
          ),
        ),
      ],
    );

    final panes = [
      homePane,
      searchPane,
      const SettingsPage(wideMode: true),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? const [
                    Color(0xFF0F0F1A),
                    Color(0xFF1A1A2E),
                    Color(0xFF16213E),
                  ]
                : const [
                    Color(0xFFF0F4F8),
                    Color(0xFFE8EEF5),
                    Color(0xFFD9E2EC),
                  ],
          ),
        ),
        child: Column(
          children: [
            SafeArea(
              top: true,
              bottom: false,
              child: TopNavigationBar(
                currentIndex: _currentIndex,
                onIndexChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                titles: navTitles,
                icons: _navIcons,
                activeIcons: _navActiveIcons,
                isDarkMode: isDarkMode,
              ),
            ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: panes,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailPlaceholder(BuildContext context, AppLocalizations localizations) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.directions_bus_outlined,
            size: 72,
            color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.25),
          ),
          const SizedBox(height: 16),
          Text(
            localizations.nearbyStations,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.5),
                ),
          ),
          const SizedBox(height: 4),
          Text(
            localizations.stationDetail,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4),
                ),
          ),
        ],
      ),
    );
  }
}
