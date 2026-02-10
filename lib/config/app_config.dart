class AppConfig {
  static const String baseUrlProduction = 'https://app.szgjgs.com:58050';
  static const String baseUrlDevelopment = 'https://app.szgjgs.com:58070';
  static const String apiPath = '/smartbus/forservice/mobile/BusService/MiniApps';

  static bool useDevelopment = false;

  static String get baseUrl => useDevelopment ? baseUrlDevelopment : baseUrlProduction;
}
