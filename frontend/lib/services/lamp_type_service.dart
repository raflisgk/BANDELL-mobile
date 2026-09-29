import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/lamp_type_model.dart';
import 'api_service.dart';

class LampTypeService {
  static List<LampTypeModel> _cachedLampTypes = [];

  /// Cek apakah cache jenis lampu tersedia
  static bool get hasCache => _cachedLampTypes.isNotEmpty;

  /// Ambil jenis lampu dari cache
  static List<LampTypeModel> get cachedLampTypes => _cachedLampTypes;

  /// Bersihkan seluruh cache jenis lampu
  static void clearCache() {
    _cachedLampTypes.clear();
  }

  /// Mengambil semua jenis lampu dari Laravel API
  Future<List<LampTypeModel>> getLampTypes({bool forceRefresh = false}) async {
    if (!forceRefresh && _cachedLampTypes.isNotEmpty) {
      return _cachedLampTypes;
    }

    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/lamp-types'),
      headers: ApiService.defaultHeaders,
    );

    debugPrint('LAMP TYPE STATUS: ${response.statusCode}');
    debugPrint('LAMP TYPE BODY: ${response.body}');

    if (response.statusCode != 200) {
      if (_cachedLampTypes.isNotEmpty) {
        return _cachedLampTypes;
      }
      throw Exception('Gagal mengambil data jenis lampu.');
    }

    final responseData = jsonDecode(response.body);

    final List data = responseData['data'] ?? [];

    final list = data
        .map((item) => LampTypeModel.fromJson(item as Map<String, dynamic>))
        .toList();

    _cachedLampTypes = list;
    return list;
  }
}
