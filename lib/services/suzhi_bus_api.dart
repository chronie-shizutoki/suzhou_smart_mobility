import 'dart:math';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../utils/decrypt_util.dart';
import '../utils/custom_http_client.dart';
import 'package:flutter/foundation.dart';

class SuZhiBusAPI {
  static final http.Client _client = CustomHttpClient.createClient();

  static String _buildUrl(String endpoint) {
    final url = '${AppConfig.baseUrl}${AppConfig.apiPath}$endpoint';
    kDebugMode ? print('API URL: $url') : null;
    return url;
  }

  static String generateRequestId() {
    final random = Random();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final randomPart = random.nextInt(1000000).toString().padLeft(6, '0');
    return '$timestamp$randomPart';
  }

  static String generateNonce() {
    final random = Random();
    final chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final nonce = List.generate(8, (index) => chars[random.nextInt(chars.length)]).join();
    return nonce;
  }

  static int generateTimestamp() {
    return DateTime.now().millisecondsSinceEpoch ~/ 1000;
  }

  static Map<String, String> _buildHeaders() {
    final nonce = generateNonce();
    final timestamp = generateTimestamp();
    return {
      'Host': 'app.szgjgs.com:58050',
      'Connection': 'keep-alive',
      'nonce': nonce,
      'content-type': 'application/json',
      'timestamp': timestamp.toString(),
      'Accept-Encoding': 'gzip,compress,br,deflate',
      'User-Agent': 'Mozilla/5.0 (iPhone; CPU OS 18_7 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Mobile/15E148 MicroMessenger/8.0.69(0x18004524) NetType/5G Language/zh_CN',
    };
  }

  static Future<Map<String, dynamic>> queryNearbyStations(
    double longitude,
    double latitude, {
    int range = 800,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_NearbyStatInfo')).replace(
        queryParameters: {
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
          'range': range.toString(),
        },
      );

      final headers = _buildHeaders();
      kDebugMode ? print('Request URL: $uri') : null;
      kDebugMode ? print('Request headers: $headers') : null;
      
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      kDebugMode ? print('Error in queryNearbyStations: $e') : null;
      throw Exception('Failed to query nearby stations: $e');
    }
  }

  static Future<Map<String, dynamic>> queryStationVehicles(
    String stationId,
    String requestId, {
    double? longitude,
    double? latitude,
    String? segmentId,
  }) async {
    try {
      final queryParams = <String, String>{
        'stationId': stationId,
        'requestId': requestId,
      };

      if (longitude != null) {
        queryParams['longitude'] = longitude.toString();
      }
      if (latitude != null) {
        queryParams['latitude'] = latitude.toString();
      }
      if (segmentId != null) {
        queryParams['segmentId'] = segmentId;
      }

      final uri = Uri.parse(_buildUrl('/Query_ByStationID')).replace(
        queryParameters: queryParams,
      );

      final headers = _buildHeaders();
      kDebugMode ? print('Query_ByStationID URL: $uri') : null;
      kDebugMode ? print('Query_ByStationID headers: $headers') : null;
      
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      
      kDebugMode ? print('Query_ByStationID response: $decrypted') : null;
      kDebugMode ? print('Query_ByStationID status: ${decrypted['status']}') : null;
      kDebugMode ? print('Query_ByStationID items: ${decrypted['items']}') : null;
      kDebugMode ? print('Query_ByStationID msg: ${decrypted['msg']}') : null;
      
      return decrypted;
    } catch (e) {
      kDebugMode ? print('Error in queryStationVehicles: $e') : null;
      throw Exception('Failed to query station vehicles: $e');
    }
  }

  static Future<Map<String, dynamic>> searchStations(String stationName) async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_ByStationName')).replace(
        queryParameters: {'stationName': stationName},
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to search stations: $e');
    }
  }

  static Future<Map<String, dynamic>> searchRoutes(
    double longitude,
    double latitude,
  ) async {
    try {
      final uri = Uri.parse(_buildUrl('/Require_AllRouteData')).replace(
        queryParameters: {
          'longitude': longitude.toString(),
          'latitude': latitude.toString(),
        },
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to search routes: $e');
    }
  }

  static Future<Map<String, dynamic>> getRouteDetail(String segmentId) async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_BusBySegmentID')).replace(
        queryParameters: {'segmentId': segmentId},
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to get route detail: $e');
    }
  }

  static Future<Map<String, dynamic>> getTimetable(String segmentId) async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_TimetableBySegmentID')).replace(
        queryParameters: {'segmentId': segmentId},
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to get timetable: $e');
    }
  }

  static Future<Map<String, dynamic>> getRouteNotices(String routeId) async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_NoticeMsgByRouteID')).replace(
        queryParameters: {'routeId': routeId},
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to get route notices: $e');
    }
  }

  static Future<Map<String, dynamic>> getAllNotices() async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_NoticeMsg'));

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to get all notices: $e');
    }
  }

  static Future<Map<String, dynamic>> getNoticeDetail(String noticeId) async {
    try {
      final uri = Uri.parse(_buildUrl('/Query_NoticeMsgByNoticeID')).replace(
        queryParameters: {'noticeId': noticeId},
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to get notice detail: $e');
    }
  }

  static Future<Map<String, dynamic>> getRouteStationData(String routeId) async {
    try {
      final uri = Uri.parse(_buildUrl('/Require_RouteStatData')).replace(
        queryParameters: {'routeId': routeId},
      );

      final headers = _buildHeaders();
      final response = await _client.get(uri, headers: headers);
      final decrypted = DecryptUtil.decryptResponseToJson(response);
      return decrypted;
    } catch (e) {
      throw Exception('Failed to get route station data: $e');
    }
  }
}
