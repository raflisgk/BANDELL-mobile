import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/lamp_type_model.dart';
import 'api_service.dart';
import 'local_cache_service.dart';

class LampTypeService {
  static void clearCache() {}

  static List<LampTypeModel> _parseList(List<dynamic> list) {
    return list
        .map((item) => LampTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil semua jenis lampu murni menggunakan Storage HP (Local Storage)
  Future<List<LampTypeModel>> getLampTypes({bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final localJson = await LocalCacheService.getLampTypesJson();
      if (localJson != null && localJson.isNotEmpty) {
        return _parseList(localJson);
      }
    }

    try {
      final response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/lamp-types'),
            headers: ApiService.defaultHeaders,
          )
          .timeout(const Duration(seconds: 10));

      debugPrint('LAMP TYPE STATUS: ${response.statusCode}');

      if (response.statusCode == 401) {
        await ApiService.handleUnauthorized();
        throw const ApiException('Sesi login telah berakhir.', statusCode: 401);
      }

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final List data = responseData['data'] ?? [];

        await LocalCacheService.saveLampTypesJson(data);

        return _parseList(data);
      }
    } catch (e) {
      if (e is ApiException && e.statusCode == 401) {
        rethrow;
      }
      debugPrint('getLampTypes error: $e. Using local storage HP fallback.');
    }

    final fallbackJson = await LocalCacheService.getLampTypesJson();
    if (fallbackJson != null && fallbackJson.isNotEmpty) {
      return _parseList(fallbackJson);
    }
    throw Exception('Gagal mengambil data jenis lampu.');
  }
}
