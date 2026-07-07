import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';

import 'package:http/http.dart' as http;

import '../storage/local_storage_service.dart';
import 'api_exception.dart';

import 'package:flutter/foundation.dart';

class ApiClient {
  // Base URL del backend. Por defecto apunta al backend desplegado en Render.
  // Para usar un backend local, ejecutar con:
  //   flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1   (emulador Android)
  //   flutter run --dart-define=API_BASE_URL=http://localhost:8080/api/v1  (iOS / web / desktop)
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://courtly-backend.onrender.com/api/v1',
  );

  final LocalStorageService localStorageService;
  final http.Client _client;

  /// Timeout por intento. El backend gratuito de Render puede tardar en
  /// responder el primer request tras dormirse.
  final Duration timeout;

  /// Reintentos adicionales ante fallos transitorios (timeout, red caida o
  /// 5xx por cold start). El total cubre el arranque tipico del backend.
  final int maxRetries;

  ApiClient(
    this.localStorageService, {
    http.Client? client,
    this.timeout = const Duration(seconds: 20),
    this.maxRetries = 3,
  }) : _client = client ?? http.Client();

  Future<Map<String, String>> _headers() async {
    final token = await localStorageService.getToken();

    debugPrint('Token disponible: ${token != null && token.isNotEmpty}');
    debugPrint('Token preview: ${token == null ? 'null' : token.substring(0, token.length > 12 ? 12 : token.length)}');

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  /// Ejecuta una peticion con timeout y reintentos ante fallos transitorios.
  /// Reintenta en timeout, errores de red y respuestas 502/503/504 (cold start).
  /// No reintenta ante errores definitivos (4xx).
  Future<http.Response> _sendWithRetry(
    Future<http.Response> Function() send,
  ) async {
    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await send().timeout(timeout);

        if (_isTransientStatus(response.statusCode) && attempt < maxRetries) {
          await Future.delayed(_backoff(attempt));
          continue;
        }

        return response;
      } on TimeoutException {
        if (attempt >= maxRetries) break;
        await Future.delayed(_backoff(attempt));
      } on SocketException {
        if (attempt >= maxRetries) break;
        await Future.delayed(_backoff(attempt));
      } on http.ClientException {
        if (attempt >= maxRetries) break;
        await Future.delayed(_backoff(attempt));
      }
    }

    throw const ApiException(
      'No se pudo conectar con el servidor. Puede estar iniciando, '
      'intenta de nuevo en unos segundos.',
      isConnectivity: true,
    );
  }

  bool _isTransientStatus(int status) =>
      status == 502 || status == 503 || status == 504;

  Duration _backoff(int attempt) =>
      Duration(milliseconds: 800 * (1 << attempt));

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _sendWithRetry(() async => _client.get(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
        ));

    return _handleResponse(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _sendWithRetry(() async => _client.get(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
        ));

    return _handleListResponse(response);
  }

  Future<Map<String, dynamic>> post(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _sendWithRetry(() async => _client.post(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        ));

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
    String path,
    Map<String, dynamic> body,
  ) async {
    final response = await _sendWithRetry(() async => _client.put(
          Uri.parse('$baseUrl$path'),
          headers: await _headers(),
          body: jsonEncode(body),
        ));

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (_isSuccess(response.statusCode)) {
      if (response.body.isEmpty) return {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    throw _errorFor(response);
  }

  List<dynamic> _handleListResponse(http.Response response) {
    if (_isSuccess(response.statusCode)) {
      if (response.body.isEmpty) return [];
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw _errorFor(response);
  }

  bool _isSuccess(int status) => status >= 200 && status < 300;

  ApiException _errorFor(http.Response response) {
    return ApiException(
      'Request failed: ${response.statusCode} - ${response.body}',
      statusCode: response.statusCode,
      isConnectivity: response.statusCode >= 500,
    );
  }
}
