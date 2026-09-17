import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

/// Clean custom exception class that shields the UI from raw system errors
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class ApiService {
  /// Base URL endpoint Laravel backend API
  static const String baseUrl = 'http://192.168.1.44:8000/api';

  /// Returns the base URL for public storage files (e.g. http://192.168.1.44:8000/storage)
  static String get storageBaseUrl {
    final uri = Uri.tryParse(baseUrl);
    if (uri != null && uri.hasScheme && uri.host.isNotEmpty) {
      final portPart = uri.hasPort ? ':${uri.port}' : '';
      return '${uri.scheme}://${uri.host}$portPart/storage';
    }
    return 'http://192.168.1.44:8000/storage';
  }

  /// Converts any photo path or partial URL into a fully-qualified, accessible URL for the mobile device.
  static String resolvePhotoUrl(String? raw) {
    if (raw == null || raw.trim().isEmpty) {
      return '';
    }

    String path = raw.trim().replaceAll(r'\', '/');

    // If already an absolute local file on device, leave it alone
    if (path.startsWith('/') &&
        !path.startsWith('/storage') &&
        !path.startsWith('/installations')) {
      return path;
    }
    if (RegExp(r'^[a-zA-Z]:[/\\]').hasMatch(path)) {
      return path;
    }

    final baseStorage = storageBaseUrl;

    // If it's already an HTTP / HTTPS URL:
    if (path.startsWith('http://') || path.startsWith('https://')) {
      // Replace localhost or 127.0.0.1 with the actual host from baseUrl
      if (path.contains('localhost') || path.contains('127.0.0.1')) {
        final parsed = Uri.tryParse(path);
        final baseUri = Uri.tryParse(baseUrl);
        if (parsed != null && baseUri != null) {
          path = parsed.replace(
            scheme: baseUri.scheme,
            host: baseUri.host,
            port: baseUri.hasPort ? baseUri.port : null,
          ).toString();
        }
      }
      return path;
    }

    // Strip leading slashes
    while (path.startsWith('/')) {
      path = path.substring(1);
    }

    // Strip 'public/' if present
    if (path.startsWith('public/')) {
      path = path.substring('public/'.length);
    }

    // Strip 'storage/' if present so we don't end up with /storage/storage/
    if (path.startsWith('storage/')) {
      path = path.substring('storage/'.length);
    }

    return '$baseStorage/$path';
  }

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

  static Future<Map<String, dynamic>> getProfile(int userId) async {
    final response = await http.get(
      Uri.parse('$baseUrl/profile?user_id=$userId'),
      headers: defaultHeaders,
    );

    debugPrint('GET PROFILE STATUS: ${response.statusCode}');
    debugPrint('GET PROFILE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data profile.');
    }

    return jsonDecode(response.body) as Map<String, dynamic>;
  }

  static String? get authToken => _authToken;

  /// Default headers yang akan dikirim pada setiap request API
  static Map<String, String> get defaultHeaders => {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
        'Connection': 'close',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Headers untuk upload multipart (file/foto)
  static Map<String, String> get multipartHeaders => {
        'Accept': 'application/json',
        'Connection': 'close',
        if (_authToken != null) 'Authorization': 'Bearer $_authToken',
      };

  /// Endpoint login
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$baseUrl/login'),
            headers: defaultHeaders,
            body: jsonEncode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 15));
    } on TimeoutException catch (e) {
      debugPrint('LOGIN TIMEOUT EXCEPTION: $e');
      throw const ApiException('Koneksi ke server timeout.');
    } on http.ClientException catch (e) {
      debugPrint('LOGIN CLIENT EXCEPTION: $e');
      throw const ApiException('Koneksi ke server gagal.');
    } on SocketException catch (e) {
      debugPrint('LOGIN SOCKET EXCEPTION: $e');
      throw const ApiException('Koneksi ke server gagal.');
    } catch (e) {
      debugPrint('LOGIN NETWORK EXCEPTION: $e');
      throw const ApiException('Koneksi ke server gagal.');
    }

    debugPrint('LOGIN STATUS CODE: ${response.statusCode}');
    debugPrint('LOGIN BODY: ${response.body}');

    Map<String, dynamic>? data;
    try {
      final dynamic decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        data = decoded;
      }
    } catch (e) {
      debugPrint('LOGIN JSON PARSE ERROR: $e');
    }

    if (response.statusCode == 200) {
      if (data != null && data['user'] != null) {
        AuthService.currentUser =
            UserModel.fromJson(data['user'] as Map<String, dynamic>);
      }
      return data ?? {};
    }

    // 401: Kredensial tidak valid
    if (response.statusCode == 401) {
      throw const ApiException(
        'Email atau password salah.',
        statusCode: 401,
      );
    }

    // 422: Validasi input gagal dari backend
    if (response.statusCode == 422) {
      String validationMsg = 'Format email atau password tidak valid.';
      if (data != null) {
        if (data['errors'] is Map && (data['errors'] as Map).isNotEmpty) {
          final firstKey = (data['errors'] as Map).keys.first;
          final firstVal = (data['errors'] as Map)[firstKey];
          if (firstVal is List && firstVal.isNotEmpty) {
            final raw = firstVal.first.toString();
            if (raw.toLowerCase().contains('email')) {
              validationMsg = 'Format email tidak valid.';
            } else if (raw.toLowerCase().contains('password')) {
              validationMsg = 'Password harus diisi.';
            } else {
              validationMsg = raw;
            }
          }
        } else if (data['message'] != null) {
          final rawMsg = data['message'].toString();
          if (rawMsg.toLowerCase().contains('email')) {
            validationMsg = 'Format email tidak valid.';
          } else {
            validationMsg = rawMsg;
          }
        }
      }
      throw ApiException(validationMsg, statusCode: 422);
    }

    // 500+: Server error
    if (response.statusCode >= 500) {
      throw ApiException(
        'Terjadi kesalahan pada server.',
        statusCode: response.statusCode,
      );
    }

    // Status code lainnya
    final safeMsg = data?['message']?.toString();
    final bool isSafe = safeMsg != null &&
        safeMsg.isNotEmpty &&
        !safeMsg.toLowerCase().contains('exception') &&
        !safeMsg.toLowerCase().contains('error') &&
        !safeMsg.contains('(') &&
        !safeMsg.contains('{');

    throw ApiException(
      isSafe ? safeMsg : 'Terjadi kesalahan. Silakan coba lagi.',
      statusCode: response.statusCode,
    );
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

  /// Endpoint untuk mengambil assignment project teknisi berdasarkan user_id
  static Future<List<dynamic>> getProjectAssignments(int userId) async {
    final uri = Uri.parse('$baseUrl/project-assignments?user_id=$userId');

    debugPrint('DEBUG USER ID FOR ASSIGNMENTS: $userId');
    debugPrint('DEBUG PROJECT ASSIGNMENTS URL: $uri');

    final response = await http.get(
      uri,
      headers: defaultHeaders,
    );

    debugPrint('DEBUG PROJECT ASSIGNMENTS STATUS: ${response.statusCode}');
    debugPrint('DEBUG PROJECT ASSIGNMENTS BODY: ${response.body}');

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
