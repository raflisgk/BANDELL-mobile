import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/project_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ProjectService {
  static ProjectModel? selectedProject;

  static List<ProjectModel> _projects = [];

  /// Nama project untuk dropdown
  static List<String> get projectOptions {
    return _projects.map((project) => project.name).toList();
  }

  /// Mengambil project yang ditugaskan kepada teknisi dari Laravel API
  /// Endpoint sumber utama: GET /api/project-assignments?user_id={user_id}
  Future<List<ProjectModel>> getProjects([int? userId]) async {
    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint('ProjectService: user_id tidak valid ($targetUserId), daftar project kosong.');
      _projects = [];
      return [];
    }

    try {
      final rawList = await ApiService.getProjectAssignments(targetUserId);

      // Ambil objek project dari setiap assignment dan hilangkan duplikasi berdasarkan project.id
      final Map<int, ProjectModel> uniqueProjects = {};

      for (final item in rawList) {
        if (item is Map<String, dynamic> && item['project'] is Map<String, dynamic>) {
          final project = ProjectModel.fromJson(
            item['project'] as Map<String, dynamic>,
          );
          uniqueProjects[project.id] = project;
        }
      }

      final projects = uniqueProjects.values.toList();
      projects.sort((a, b) => a.id.compareTo(b.id));

      _projects = projects;
      return projects;
    } catch (e) {
      debugPrint('Error getting assigned projects: $e');
      rethrow;
    }
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