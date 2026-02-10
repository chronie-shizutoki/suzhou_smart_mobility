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
      ..userAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36';

    return http_io.IOClient(httpClient);
  }
}
