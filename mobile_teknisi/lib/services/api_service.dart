import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
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

  static Future<Map<String, dynamic>> updateProfilePhone({
  required int userId,
  required String phoneNumber,
}) async {
  final response = await http.put(
    Uri.parse('$baseUrl/profile/phone'),
    headers: defaultHeaders,
    body: jsonEncode({
      'user_id': userId,
      'phone_number': phoneNumber,
    }),
  );

  debugPrint('UPDATE PROFILE STATUS: ${response.statusCode}');
  debugPrint('UPDATE PROFILE BODY: ${response.body}');

  Map<String, dynamic> responseData;

  try {
    responseData = jsonDecode(response.body) as Map<String, dynamic>;
  } catch (_) {
    throw Exception('Response server tidak valid.');
  }

  if (response.statusCode == 200 && responseData['success'] == true) {
    return responseData;
  }

  throw Exception(
    responseData['message']?.toString() ??
        'Gagal memperbarui nomor telepon.',
  );
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

  /// Endpoint untuk mengambil notifikasi penugasan project berdasarkan user_id
  static Future<List<dynamic>> getNotifications(int userId) async {
    final uri = Uri.parse('$baseUrl/notifications?user_id=$userId');

    debugPrint('DEBUG USER ID: $userId');
    debugPrint('DEBUG NOTIFICATION URL: $uri');

    final response = await http.get(
      uri,
      headers: defaultHeaders,
    );

    debugPrint('DEBUG NOTIFICATION STATUS: ${response.statusCode}');
    debugPrint('DEBUG NOTIFICATION BODY: ${response.body}');

    if (response.statusCode == 200) {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic> &&
          decoded['success'] == true &&
          decoded['data'] is List) {
        return decoded['data'] as List<dynamic>;
      }
    }

    return [];
  }
}
