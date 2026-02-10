import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart' as enc;
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class DecryptUtil {
  static String decryptResponse(http.Response response) {
    kDebugMode ? print('Response status: ${response.statusCode}') : null;
    kDebugMode ? print('Response headers: ${response.headers}') : null;
    kDebugMode ? print('Response body length: ${response.body.length}') : null;
    
    final iv = response.headers['x-encryption-iv'];
    final encryptedData = response.body;
    final nonce = response.headers['nonce'];
    final timestamp = response.headers['timestamp'];

    if (iv == null || nonce == null || timestamp == null) {
      final missingHeaders = <String>[];
      if (iv == null) missingHeaders.add('x-encryption-iv');
      if (nonce == null) missingHeaders.add('nonce');
      if (timestamp == null) missingHeaders.add('timestamp');
      
      throw Exception('Missing required encryption headers: ${missingHeaders.join(', ')}\n'
          'Response status: ${response.statusCode}\n'
          'Response headers: ${response.headers}\n'
          'Response body: ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}');
    }

    final key = _md5('$nonce\$$timestamp');

    final keyParsed = enc.Key.fromUtf8(key);
    final ivParsed = enc.IV.fromBase64(iv);

    final encrypter = enc.Encrypter(enc.AES(keyParsed, mode: enc.AESMode.cbc));
    final decrypted = encrypter.decrypt64(encryptedData, iv: ivParsed);

    return decrypted;
  }

  static String _md5(String input) {
    final bytes = utf8.encode(input);
    final digest = md5.convert(bytes);
    return digest.toString();
  }

  static Map<String, dynamic> decryptResponseToJson(http.Response response) {
    final decrypted = decryptResponse(response);
    return jsonDecode(decrypted) as Map<String, dynamic>;
  }
}
