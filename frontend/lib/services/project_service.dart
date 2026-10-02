import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../models/project_model.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'local_cache_service.dart';

class ProjectService {
  static ProjectModel? selectedProject;
  static List<ProjectModel> _projects = [];

  /// Cek apakah ada project yang sedang aktif
  static bool get hasCachedProjects => _projects.isNotEmpty;

  /// Ambil project yang tersimpan saat ini
  static List<ProjectModel> get cachedProjects => List.unmodifiable(_projects);

  /// Nama project untuk dropdown
  static List<String> get projectOptions {
    return _projects.map((project) => project.name).toList();
  }

  /// Bersihkan data (saat logout dsb)
  static void clearCache() {
    _projects = [];
    selectedProject = null;
  }

  /// Resolves area name by area ID from current list or Storage HP
  static String? getAreaName(int? projectId, int? areaId) {
    if (areaId == null || areaId <= 0) return null;
    return null;
  }

  /// Mengambil project yang ditugaskan kepada teknisi dari Storage HP / API
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

    if (!forceRefresh) {
      final cachedJson = await LocalCacheService.getProjectsJson(targetUserId);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        _parseAndSetProjects(cachedJson);
        return _projects;
      }
    }

    try {
      final rawList = await ApiService.getProjectAssignments(targetUserId);

      // Simpan ke Storage HP
      await LocalCacheService.saveProjectsJson(targetUserId, rawList);

      _parseAndSetProjects(rawList);
      _prefetchAllProjectAreas(_projects);
      return _projects;
    } catch (e) {
      debugPrint('Error getting assigned projects: $e. Using local storage fallback.');
      final cachedJson = await LocalCacheService.getProjectsJson(targetUserId);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        _parseAndSetProjects(cachedJson);
        return _projects;
      }
      if (_projects.isNotEmpty) {
        return _projects;
      }
      rethrow;
    }
  }

  static void _parseAndSetProjects(List<dynamic> rawList) {
    final Map<int, ProjectModel> uniqueProjects = {};
    for (final item in rawList) {
      if (item is Map<String, dynamic> &&
          item['project'] is Map<String, dynamic>) {
        final projectMap = item['project'] as Map<String, dynamic>;
        final project = ProjectModel.fromJson(projectMap);
        uniqueProjects[project.id] = project;

        // Pre-cache areas/districts jika disertakan di dalam data project
        if (projectMap['districts'] is List) {
          final districts = (projectMap['districts'] as List).map((d) {
            if (d is Map<String, dynamic>) {
              return {
                ...d,
                'status': d['status'] ?? 'aktif',
              };
            }
            return d;
          }).toList();
          LocalCacheService.saveProjectAreasJson(project.id, districts);
        }
      }
    }
    final projects = uniqueProjects.values.toList();
    projects.sort((a, b) => a.id.compareTo(b.id));
    _projects = projects;
  }

  static void _prefetchAllProjectAreas(List<ProjectModel> projects) {
    for (final p in projects) {
      Future(() async {
        try {
          final res = await http
              .get(
                Uri.parse('${ApiService.baseUrl}/projects/${p.id}/areas'),
                headers: ApiService.defaultHeaders,
              )
              .timeout(const Duration(seconds: 4));
          if (res.statusCode == 200) {
            final data = jsonDecode(res.body);
            final list = (data['data'] as List<dynamic>?) ?? [];
            await LocalCacheService.saveProjectAreasJson(p.id, list);
          }
        } catch (_) {}
      });
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

  /// Mengambil area berdasarkan project murni menggunakan Storage HP (Local Storage)
  Future<List<dynamic>> getAreas(
    int projectId, {
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      final localAreas = await LocalCacheService.getProjectAreasJson(projectId);
      if (localAreas != null) {
        return localAreas;
      }
    }

    final http.Response response;
    try {
      response = await http
          .get(
            Uri.parse('${ApiService.baseUrl}/projects/$projectId/areas'),
            headers: ApiService.defaultHeaders,
          )
          .timeout(const Duration(seconds: 3));

      debugPrint('AREA STATUS: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final areaList = (responseData['data'] as List<dynamic>?) ?? [];
        await LocalCacheService.saveProjectAreasJson(projectId, areaList);
        return areaList;
      }
    } catch (e) {
      debugPrint('getAreas error: $e. Using local storage fallback.');
      final localAreas = await LocalCacheService.getProjectAreasJson(projectId);
      if (localAreas != null) {
        return localAreas;
      }
      return [];
    }

    final fallbackAreas = await LocalCacheService.getProjectAreasJson(projectId);
    if (fallbackAreas != null) {
      return fallbackAreas;
    }
    return [];
  }
}
