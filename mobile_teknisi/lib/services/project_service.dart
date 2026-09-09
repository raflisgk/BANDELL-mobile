import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/project_model.dart';
import 'api_service.dart';

class ProjectService {
  static ProjectModel? selectedProject;

  static List<ProjectModel> _projects = [];

  /// Nama project untuk dropdown
  static List<String> get projectOptions {
    return _projects.map((project) => project.name).toList();
  }

  /// Mengambil semua project dari Laravel
  Future<List<ProjectModel>> getProjects() async {
    final response = await http.get(
      Uri.parse('${ApiService.baseUrl}/projects'),
      headers: ApiService.defaultHeaders,
    );

    debugPrint('PROJECT STATUS: ${response.statusCode}');
    debugPrint('PROJECT BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data project.');
    }

    final responseData = jsonDecode(response.body);

    final List data = responseData['data'] ?? [];

    final projects = data
        .map(
          (item) => ProjectModel.fromJson(
            item as Map<String, dynamic>,
          ),
        )
        .toList();

    // Aktif di atas, selesai di bawah.
    projects.sort((a, b) {
      if (a.isActive && b.isCompleted) {
        return -1;
      }

      if (a.isCompleted && b.isActive) {
        return 1;
      }

      return a.id.compareTo(b.id);
    });

    _projects = projects;

    return projects;
  }

  /// Ambil project berdasarkan ID
  static ProjectModel? getProjectById(int id) {
    try {
      return _projects.firstWhere(
        (project) => project.id == id,
      );
    } catch (_) {
      return null;
    }
  }

  /// Versi synchronous untuk kode lama
  static ProjectModel? getProjectByIdSync(int id) {
    return getProjectById(id);
  }

  /// Ambil project berdasarkan nama
  static ProjectModel? getProjectByName(String name) {
    try {
      return _projects.firstWhere(
        (project) => project.name == name,
      );
    } catch (_) {
      return null;
    }
  }

  /// Mengambil area berdasarkan project
  Future<List<dynamic>> getAreas(int projectId) async {
    final response = await http.get(
      Uri.parse(
        '${ApiService.baseUrl}/projects/$projectId/areas',
      ),
      headers: ApiService.defaultHeaders,
    );

    debugPrint('AREA STATUS: ${response.statusCode}');
    debugPrint('AREA BODY: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil area operasional.');
    }

    final responseData = jsonDecode(response.body);

    return responseData['data'] ?? [];
  }
}