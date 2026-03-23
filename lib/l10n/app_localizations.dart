import 'dart:async';
import 'package:flutter/material.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedValues = {
    'en': {
      'appTitle': 'Suzhou Smart Mobility',
      'home': 'Home',
      'search': 'Search',
      'settings': 'Settings',
      'nearbyStations': 'Nearby Stations',
      'queryNearbyStations': 'Query Nearby Stations',
      'distance': 'Distance',
      'meters': 'm',
      'latitude': 'Lat',
      'longitude': 'Lon',
      'stationId': 'Station ID',
      'searchRoutes': 'Search Routes',
      'routes': 'Routes',
      'from': 'From',
      'to': 'To',
      'notAvailable': 'N/A',
      'searchStations': 'Stations',
      'searchPlaceholder': 'Search stations or routes...',
      'theme': 'Theme',
      'darkMode': 'Dark Mode',
      'language': 'Language',
      'about': 'About',
      'version': 'Version',
      'failedToGetLocation': 'Failed to get location. Please check permissions.',
      'unknownError': 'Unknown error',
      'loading': 'Loading...',
      'noData': 'No data available',
      'routeId': 'Route ID',
      'routeName': 'Route Name',
      'startStation': 'Start Station',
      'endStation': 'End Station',
      'stationName': 'Station Name',
      'routeDetail': 'Route Detail',
      'stationDetail': 'Station Detail',
      'stations': 'Stations',
      'buses': 'Buses',
      'timetable': 'Timetable',
      'plateNumber': 'Plate Number',
      'lightTheme': 'Light',
      'darkTheme': 'Dark',
      'systemTheme': 'System',
      'alwaysUseLight': 'Always use light theme',
      'alwaysUseDark': 'Always use dark theme',
      'followSystem': 'Follow system theme',
      'firstBus': 'First',
      'lastBus': 'Last',
      'minutes': 'minutes',
      'arrivingSoon': 'Arriving soon',
      'busAtStation': 'Bus at station',
      'notStarted': 'Not started',
      'ended': 'Ended',
      'notOperatingToday': 'Not operating today',
      'walking': 'Walking',
      'withinMinutes': 'within minutes',
      'waitingForDeparture': 'Waiting for departure',
      'runDirection': 'Run Direction',
      'ticketPrice': 'Ticket Price',
      'yuan': 'yuan',
      'flipPrice': 'Flip Price',
      'nextDeparture': 'Next Departure',
      'estimatedDeparture': 'Estimated Departure',
      'hasPassedLastDeparture': 'Has passed last departure',
      'highPeak': 'High Peak',
      'plainPeak': 'Plain Peak',
      'lowPeak': 'Low Peak',
      'stationsAway': 'stations away',
      'km': 'km',
      'within100m': 'Within 100m',
      'refresh': 'Refresh',
      'reverse': 'Reverse',
      'collect': 'Collect',
      'collected': 'Collected',
      'feedback': 'Feedback',
      'vertical': 'Vertical',
      'more': 'More',
      'careMode': 'Care Mode',
      'careModeDescription': 'Larger fonts and higher contrast for better readability',
      'careModeEnabled': 'Care mode enabled',
      'careModeDisabled': 'Care mode disabled',
      'locationNotInSuzhou': 'You are not currently in Suzhou',
    },
    'zh': {
      'appTitle': '苏智出行',
      'home': '首页',
      'search': '搜索',
      'settings': '设置',
      'nearbyStations': '附近站点',
      'queryNearbyStations': '查询附近站点',
      'distance': '距离',
      'meters': '米',
      'latitude': '纬度',
      'longitude': '经度',
      'stationId': '站点ID',
      'searchRoutes': '搜索线路',
      'routes': '线路',
      'from': '起点',
      'to': '开往',
      'notAvailable': '未知',
      'searchStations': '站点',
      'searchPlaceholder': '搜索站点或线路...',
      'theme': '主题',
      'darkMode': '深色模式',
      'language': '语言',
      'about': '关于',
      'version': '版本',
      'failedToGetLocation': '无法获取位置信息，请检查权限设置。',
      'unknownError': '未知错误',
      'loading': '加载中...',
      'noData': '暂无数据',
      'routeId': '线路ID',
      'routeName': '线路名称',
      'startStation': '起点站',
      'endStation': '终点站',
      'stationName': '站点名称',
      'routeDetail': '线路详情',
      'stationDetail': '站点详情',
      'stations': '站点',
      'buses': '车辆',
      'timetable': '时刻表',
      'plateNumber': '车牌号',
      'lightTheme': '浅色',
      'darkTheme': '深色',
      'systemTheme': '自动',
      'alwaysUseLight': '始终使用浅色主题',
      'alwaysUseDark': '始终使用深色主题',
      'followSystem': '跟随系统主题',
      'firstBus': '首',
      'lastBus': '末',
      'minutes': '分钟',
      'arrivingSoon': '即将进站',
      'busAtStation': '车辆进站',
      'notStarted': '营运未开始',
      'ended': '营运已结束',
      'notOperatingToday': '今日不营运',
      'walking': '步行',
      'withinMinutes': '内',
      'waitingForDeparture': '等待发车',
      'runDirection': '运行方向',
      'ticketPrice': '票价',
      'yuan': '元',
      'flipPrice': '翻牌票价',
      'nextDeparture': '预计发车',
      'estimatedDeparture': '预计发车时间',
      'hasPassedLastDeparture': '已过末班发车时间',
      'highPeak': '高峰',
      'plainPeak': '平峰',
      'lowPeak': '低峰',
      'stationsAway': '站',
      'km': 'km',
      'within100m': '100m内',
      'refresh': '刷新',
      'reverse': '换向',
      'collect': '收藏',
      'collected': '已收藏',
      'feedback': '反馈',
      'vertical': '竖版',
      'more': '更多',
      'careMode': '关怀模式',
      'careModeDescription': '更大字号和更高对比度，提升可读性',
      'careModeEnabled': '关怀模式已启用',
      'careModeDisabled': '关怀模式已关闭',
      'locationNotInSuzhou': '您当前的位置不在苏州',
    },
  };

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('zh'),
  ];

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  String get appTitle => _localizedValues[locale.languageCode]!['appTitle']!;
  String get home => _localizedValues[locale.languageCode]!['home']!;
  String get search => _localizedValues[locale.languageCode]!['search']!;
  String get settings => _localizedValues[locale.languageCode]!['settings']!;
  String get nearbyStations => _localizedValues[locale.languageCode]!['nearbyStations']!;
  String get queryNearbyStations => _localizedValues[locale.languageCode]!['queryNearbyStations']!;
  String get distance => _localizedValues[locale.languageCode]!['distance']!;
  String get meters => _localizedValues[locale.languageCode]!['meters']!;
  String get latitude => _localizedValues[locale.languageCode]!['latitude']!;
  String get longitude => _localizedValues[locale.languageCode]!['longitude']!;
  String get stationId => _localizedValues[locale.languageCode]!['stationId']!;
  String get searchRoutes => _localizedValues[locale.languageCode]!['searchRoutes']!;
  String get routes => _localizedValues[locale.languageCode]!['routes']!;
  String get from => _localizedValues[locale.languageCode]!['from']!;
  String get to => _localizedValues[locale.languageCode]!['to']!;
  String get notAvailable => _localizedValues[locale.languageCode]!['notAvailable']!;
  String get searchStations => _localizedValues[locale.languageCode]!['searchStations']!;
  String get searchPlaceholder => _localizedValues[locale.languageCode]!['searchPlaceholder']!;
  String get theme => _localizedValues[locale.languageCode]!['theme']!;
  String get darkMode => _localizedValues[locale.languageCode]!['darkMode']!;
  String get language => _localizedValues[locale.languageCode]!['language']!;
  String get about => _localizedValues[locale.languageCode]!['about']!;
  String get version => _localizedValues[locale.languageCode]!['version']!;
  String get failedToGetLocation => _localizedValues[locale.languageCode]!['failedToGetLocation']!;
  String get unknownError => _localizedValues[locale.languageCode]!['unknownError']!;
  String get loading => _localizedValues[locale.languageCode]!['loading']!;
  String get noData => _localizedValues[locale.languageCode]!['noData']!;
  String get routeId => _localizedValues[locale.languageCode]!['routeId']!;
  String get routeName => _localizedValues[locale.languageCode]!['routeName']!;
  String get startStation => _localizedValues[locale.languageCode]!['startStation']!;
  String get endStation => _localizedValues[locale.languageCode]!['endStation']!;
  String get stationName => _localizedValues[locale.languageCode]!['stationName']!;
  String get routeDetail => _localizedValues[locale.languageCode]!['routeDetail']!;
  String get stationDetail => _localizedValues[locale.languageCode]!['stationDetail']!;
  String get stations => _localizedValues[locale.languageCode]!['stations']!;
  String get buses => _localizedValues[locale.languageCode]!['buses']!;
  String get timetable => _localizedValues[locale.languageCode]!['timetable']!;
  String get plateNumber => _localizedValues[locale.languageCode]!['plateNumber']!;
  String get lightTheme => _localizedValues[locale.languageCode]!['lightTheme']!;
  String get darkTheme => _localizedValues[locale.languageCode]!['darkTheme']!;
  String get systemTheme => _localizedValues[locale.languageCode]!['systemTheme']!;
  String get alwaysUseLight => _localizedValues[locale.languageCode]!['alwaysUseLight']!;
  String get alwaysUseDark => _localizedValues[locale.languageCode]!['alwaysUseDark']!;
  String get followSystem => _localizedValues[locale.languageCode]!['followSystem']!;
  String get firstBus => _localizedValues[locale.languageCode]!['firstBus']!;
  String get lastBus => _localizedValues[locale.languageCode]!['lastBus']!;
  String get arrivingSoon => _localizedValues[locale.languageCode]!['arrivingSoon']!;
  String get busAtStation => _localizedValues[locale.languageCode]!['busAtStation']!;
  String get notStarted => _localizedValues[locale.languageCode]!['notStarted']!;
  String get ended => _localizedValues[locale.languageCode]!['ended']!;
  String get notOperatingToday => _localizedValues[locale.languageCode]!['notOperatingToday']!;
  String get walking => _localizedValues[locale.languageCode]!['walking']!;
  String get minutes => _localizedValues[locale.languageCode]!['minutes']!;
  String get withinMinutes => _localizedValues[locale.languageCode]!['withinMinutes']!;
  String get waitingForDeparture => _localizedValues[locale.languageCode]!['waitingForDeparture']!;
  String get runDirection => _localizedValues[locale.languageCode]!['runDirection']!;
  String get ticketPrice => _localizedValues[locale.languageCode]!['ticketPrice']!;
  String get yuan => _localizedValues[locale.languageCode]!['yuan']!;
  String get flipPrice => _localizedValues[locale.languageCode]!['flipPrice']!;
  String get nextDeparture => _localizedValues[locale.languageCode]!['nextDeparture']!;
  String get estimatedDeparture => _localizedValues[locale.languageCode]!['estimatedDeparture']!;
  String get hasPassedLastDeparture => _localizedValues[locale.languageCode]!['hasPassedLastDeparture']!;
  String get highPeak => _localizedValues[locale.languageCode]!['highPeak']!;
  String get plainPeak => _localizedValues[locale.languageCode]!['plainPeak']!;
  String get lowPeak => _localizedValues[locale.languageCode]!['lowPeak']!;
  String get stationsAway => _localizedValues[locale.languageCode]!['stationsAway']!;
  String get km => _localizedValues[locale.languageCode]!['km']!;
  String get within100m => _localizedValues[locale.languageCode]!['within100m']!;
  String get refresh => _localizedValues[locale.languageCode]!['refresh']!;
  String get reverse => _localizedValues[locale.languageCode]!['reverse']!;
  String get collect => _localizedValues[locale.languageCode]!['collect']!;
  String get collected => _localizedValues[locale.languageCode]!['collected']!;
  String get feedback => _localizedValues[locale.languageCode]!['feedback']!;
  String get vertical => _localizedValues[locale.languageCode]!['vertical']!;
  String get more => _localizedValues[locale.languageCode]!['more']!;
  String get careMode => _localizedValues[locale.languageCode]!['careMode']!;
  String get careModeDescription => _localizedValues[locale.languageCode]!['careModeDescription']!;
  String get careModeEnabled => _localizedValues[locale.languageCode]!['careModeEnabled']!;
  String get careModeDisabled => _localizedValues[locale.languageCode]!['careModeDisabled']!;
  String get locationNotInSuzhou => _localizedValues[locale.languageCode]!['locationNotInSuzhou']!;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
