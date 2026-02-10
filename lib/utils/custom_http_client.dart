import 'dart:io';
import 'package:http/http.dart';
import 'package:http/io_client.dart' as http_io;

class CustomHttpClient {
  static Client createClient() {
    final httpClient = HttpClient()
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return true;
      }
      ..connectionTimeout = const Duration(seconds: 30)
      ..idleTimeout = const Duration(seconds: 30)
      ..userAgent = 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN';

    return http_io.IOClient(httpClient);
  }
}
