import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/lamp_type_model.dart';
import 'api_service.dart';

class LampTypeService {
  /// Mengambil semua jenis lampu dari Laravel API
  Future<List<LampTypeModel>> getLampTypes() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/lamp-types'),
      headers: ApiService.defaultHeaders,
    );

    debugPrint('LAMP TYPE STATUS: ${response.statusCode}');
    debugPrint('LAMP TYPE BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data jenis lampu.');
    }

    final responseData = jsonDecode(response.body);

    final List data = responseData['data'] ?? [];

    return data
        .map(
          (item) => LampTypeModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();
  }
}