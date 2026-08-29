import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/operational_area.dart';

class OperationalAreaService {
  static const String baseUrl =
      'YOUR_API_URL';

  Future<List<OperationalArea>>
      getOperationalAreas(
    int idProject,
  ) async {
    final response = await http.get(
      Uri.parse(
        '$baseUrl/projects/$idProject/operational-areas',
      ),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Gagal mengambil data area',
      );
    }

    final decoded =
        jsonDecode(response.body);

    final List<dynamic> data =
        decoded is List
            ? decoded
            : decoded['data'] ?? [];

    return data
        .map(
          (item) =>
              OperationalArea.fromJson(
            item,
          ),
        )
        .toList();
  }
}