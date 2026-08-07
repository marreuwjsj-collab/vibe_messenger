import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';

final class ApiException implements Exception {
  final int statusCode;
  final String message;
  const ApiException(this.statusCode, this.message);
  @override
  String toString() => 'ApiException($statusCode): $message';
}

final class ApiClient {
  final AppConfig config;
  final http.Client _client;

  ApiClient(this.config, {http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> get(String path, {String? token}) async {
    final response = await _client
        .get(_uri(path), headers: _headers(token))
        .timeout(config.networkTimeout);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, {Object? body, String? token}) async {
    final response = await _client
        .post(_uri(path), headers: _headers(token), body: body == null ? null : jsonEncode(body))
        .timeout(config.networkTimeout);
    return _decode(response);
  }

  Uri _uri(String path) => Uri.parse('${config.apiBaseUrl}${path.startsWith('/') ? path : '/$path'}');

  Map<String, String> _headers(String? token) => {
        HttpHeaders.acceptHeader: 'application/json',
        HttpHeaders.contentTypeHeader: 'application/json',
        if (token != null) HttpHeaders.authorizationHeader: 'Bearer $token',
      };

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw ApiException(response.statusCode, response.body);
    }
    if (response.body.isEmpty) return const {};
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) throw const FormatException('Expected JSON object');
    return decoded;
  }
}
