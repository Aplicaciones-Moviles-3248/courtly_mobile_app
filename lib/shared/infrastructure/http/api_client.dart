import 'dart:convert';

import 'package:http/http.dart' as http;

import '../storage/local_storage_service.dart';

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

  ApiClient(this.localStorageService);

  Future<Map<String, String>> _headers() async {
    final token = await localStorageService.getToken();

    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> post(
      String path,
      Map<String, dynamic> body,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Future<Map<String, dynamic>> put(
      String path,
      Map<String, dynamic> body,
      ) async {
    final response = await http.put(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
      body: jsonEncode(body),
    );

    return _handleResponse(response);
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return {};
      }

      return jsonDecode(response.body) as Map<String, dynamic>;
    }

    throw Exception(
      'Request failed: ${response.statusCode} - ${response.body}',
    );
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await http.get(
      Uri.parse('$baseUrl$path'),
      headers: await _headers(),
    );

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return [];
      }

      return jsonDecode(response.body) as List<dynamic>;
    }

    throw Exception(
      'Request failed: ${response.statusCode} - ${response.body}',
    );
  }

}