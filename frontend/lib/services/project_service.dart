import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/project_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class ProjectService {
  static ProjectModel? selectedProject;

  static List<ProjectModel> _projects = [];
  static final Map<int, List<dynamic>> _cachedAreas = {};

  /// Cek apakah sudah ada cache project di memori
  static bool get hasCachedProjects => _projects.isNotEmpty;

  /// Ambil cache project yang tersimpan
  static List<ProjectModel> get cachedProjects => List.unmodifiable(_projects);

  /// Cek apakah sudah ada cache area untuk projectId tertentu
  static bool hasCachedAreas(int projectId) =>
      _cachedAreas.containsKey(projectId) &&
      _cachedAreas[projectId]!.isNotEmpty;

  /// Ambil cache area untuk projectId tertentu
  static List<dynamic> getCachedAreas(int projectId) =>
      _cachedAreas[projectId] ?? [];

  /// Nama project untuk dropdown
  static List<String> get projectOptions {
    return _projects.map((project) => project.name).toList();
  }

  /// Bersihkan seluruh cache (saat logout dsb)
  static void clearCache() {
    _projects = [];
    _cachedAreas.clear();
    selectedProject = null;
  }

  /// Mengambil project yang ditugaskan kepada teknisi dari Laravel API
  /// Endpoint sumber utama: GET /api/project-assignments?user_id={user_id}
  Future<List<ProjectModel>> getProjects([
    int? userId,
    bool forceRefresh = false,
  ]) async {
    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint(
        'ProjectService: user_id tidak valid ($targetUserId), daftar project kosong.',
      );
      _projects = [];
      return [];
    }

    if (!forceRefresh && _projects.isNotEmpty) {
      return _projects;
    }

    try {
      final rawList = await ApiService.getProjectAssignments(targetUserId);

      // Ambil objek project dari setiap assignment dan hilangkan duplikasi berdasarkan project.id
      final Map<int, ProjectModel> uniqueProjects = {};

      for (final item in rawList) {
        if (item is Map<String, dynamic> &&
            item['project'] is Map<String, dynamic>) {
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
      if (_projects.isNotEmpty) {
        return _projects;
      }
      rethrow;
    }
  }

  /// Ambil project berdasarkan ID
  static ProjectModel? getProjectById(int id) {
    try {
      return _projects.firstWhere((project) => project.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Ambil project berdasarkan nama
  static ProjectModel? getProjectByName(String name) {
    try {
      return _projects.firstWhere((project) => project.name == name);
    } catch (_) {
      return null;
    }
  }

  /// Mengambil area berdasarkan project
  Future<List<dynamic>> getAreas(
    int projectId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedAreas.containsKey(projectId)) {
      return _cachedAreas[projectId]!;
    }

    final http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/projects/$projectId/areas'),
            headers: ApiService.defaultHeaders,
          )
          .timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      if (_cachedAreas.containsKey(projectId)) {
        return _cachedAreas[projectId]!;
      }
      throw Exception('Koneksi internet bermasalah.');
    }

    debugPrint('AREA STATUS: ${response.statusCode}');
    debugPrint('AREA BODY: ${response.body}');

    if (response.statusCode != 200) {
      if (_cachedAreas.containsKey(projectId)) {
        return _cachedAreas[projectId]!;
      }
      throw Exception('Gagal mengambil area operasional.');
    }

    final responseData = jsonDecode(response.body);
    final areaList = (responseData['data'] as List<dynamic>?) ?? [];
    _cachedAreas[projectId] = areaList;

    return areaList;
  }
}
