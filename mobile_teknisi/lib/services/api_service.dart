import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/user_model.dart';
import 'auth_service.dart';

class ApiService {
  /// Base URL endpoint Laravel backend API
  static const String baseUrl = 'http://192.168.1.128:8000/api';

  /// Token session untuk autentikasi Bearer Token (opsional, jika digunakan)
  static String? _authToken;

  static void setAuthToken(String? token) {
    _authToken = token;
  }

  static String? get authToken => _authToken;

  /// Default headers yang akan dikirim pada setiap request API
  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Headers untuk upload multipart (file/foto)
  static Map<String, String> get multipartHeaders => {
        'Accept': 'application/json',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Endpoint login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: defaultHeaders,
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode != 200) {
      throw Exception(data['message'] ?? 'Login gagal.');
    }

    if (data is Map<String, dynamic> && data['user'] != null) {
      AuthService.currentUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
    }

    return data;
  }
}
