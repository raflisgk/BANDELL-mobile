import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/project.dart';

class ProjectService {
  static const String baseUrl = 'YOUR_API_URL';

  Future<List<Project>> getProjects() async {
    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: {
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      final List<dynamic> data;

      if (decoded is List) {
        data = decoded;
      } else {
        data = decoded['data'] ?? [];
      }

      return data
          .map(
            (item) => Project.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList();
    }

    throw Exception(
      'Gagal mengambil data project '
      '(HTTP ${response.statusCode})',
    );
  }
}