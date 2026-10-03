import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  static SharedPreferences? _prefs;

  static SharedPreferences? get prefs => _prefs;

  static Future<void> init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  static Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  // ==========================================
  // RIWAYAT (HISTORY) CACHE
  // ==========================================
  static String _historyKey(
    int userId,
    int projectId,
    String start,
    String end,
  ) {
    return 'cache_history_${userId}_${projectId}_${start}_$end';
  }

  static String _latestHistoryKey(int userId, int projectId) {
    return 'cache_history_latest_${userId}_$projectId';
  }

  static Future<void> saveHistoryJson({
    required int userId,
    required int projectId,
    String filter = '',
    required String start,
    required String end,
    required List<dynamic> data,
  }) async {
    try {
      final prefs = await _getPrefs();
      final key = _historyKey(userId, projectId, start, end);
      final jsonStr = jsonEncode(data);
      await prefs.setString(key, jsonStr);
      await prefs.setString(_latestHistoryKey(userId, projectId), jsonStr);
    } catch (e) {
      debugPrint('LocalCacheService saveHistory error: $e');
    }
  }

  static List<dynamic>? getHistoryJsonSync({
    required int userId,
    required int projectId,
    String filter = '',
    String start = '',
    String end = '',
  }) {
    if (_prefs == null) return null;
    try {
      final key = _historyKey(userId, projectId, start, end);
      String? raw = _prefs!.getString(key);
      raw ??= _prefs!.getString(_latestHistoryKey(userId, projectId));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getHistoryJsonSync error: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getHistoryJson({
    required int userId,
    required int projectId,
    String filter = '',
    String start = '',
    String end = '',
  }) async {
    try {
      final prefs = await _getPrefs();
      final key = _historyKey(userId, projectId, start, end);
      String? raw = prefs.getString(key);
      raw ??= prefs.getString(_latestHistoryKey(userId, projectId));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getHistory error: $e');
    }
    return null;
  }

  // ==========================================
  // LAMP TYPES CACHE
  // ==========================================
  static const String _keyLampTypes = 'cache_lamp_types';

  static Future<void> saveLampTypesJson(List<dynamic> data) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_keyLampTypes, jsonEncode(data));
    } catch (e) {
      debugPrint('LocalCacheService saveLampTypes error: $e');
    }
  }

  static List<dynamic>? getLampTypesJsonSync() {
    if (_prefs == null) return null;
    try {
      final raw = _prefs!.getString(_keyLampTypes);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getLampTypesJsonSync error: $e');
    }
    return null;
  }

  static Future<List<dynamic>?> getLampTypesJson() async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_keyLampTypes);
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getLampTypes error: $e');
    }
    return null;
  }

  // ==========================================
  // PROJECTS & AREAS CACHE
  // ==========================================
  static String _projectsKey(int userId) => 'cache_projects_user_$userId';
  static String _areasKey(int projectId) => 'cache_areas_project_$projectId';
  static const String _keySelectedProjectId = 'cache_selected_project_id';

  static Future<void> saveProjectsJson(int userId, List<dynamic> data) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_projectsKey(userId), jsonEncode(data));
    } catch (e) {
      debugPrint('LocalCacheService saveProjects error: $e');
    }
  }

  static Future<List<dynamic>?> getProjectsJson(int userId) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_projectsKey(userId));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getProjects error: $e');
    }
    return null;
  }

  static Future<void> saveProjectAreasJson(int projectId, List<dynamic> data) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_areasKey(projectId), jsonEncode(data));
    } catch (e) {
      debugPrint('LocalCacheService saveProjectAreas error: $e');
    }
  }

  static Future<List<dynamic>?> getProjectAreasJson(int projectId) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_areasKey(projectId));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getProjectAreas error: $e');
    }
    return null;
  }

  static Future<void> saveSelectedProjectId(int projectId) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setInt(_keySelectedProjectId, projectId);
    } catch (e) {
      debugPrint('LocalCacheService saveSelectedProjectId error: $e');
    }
  }

  static Future<int?> getSelectedProjectId() async {
    try {
      final prefs = await _getPrefs();
      return prefs.getInt(_keySelectedProjectId);
    } catch (e) {
      debugPrint('LocalCacheService getSelectedProjectId error: $e');
    }
    return null;
  }

  // ==========================================
  // NOTIFICATIONS CACHE
  // ==========================================
  static String _notificationsKey(int userId) => 'cache_notifications_user_$userId';
  static const String _keyReadNotificationIds = 'cache_read_notification_ids';

  static Future<void> saveNotificationsJson(int userId, List<dynamic> data) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setString(_notificationsKey(userId), jsonEncode(data));
    } catch (e) {
      debugPrint('LocalCacheService saveNotifications error: $e');
    }
  }

  static Future<List<dynamic>?> getNotificationsJson(int userId) async {
    try {
      final prefs = await _getPrefs();
      final raw = prefs.getString(_notificationsKey(userId));
      if (raw != null && raw.isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) return decoded;
      }
    } catch (e) {
      debugPrint('LocalCacheService getNotifications error: $e');
    }
    return null;
  }

  static Future<void> saveReadNotificationIds(Set<int> ids) async {
    try {
      final prefs = await _getPrefs();
      await prefs.setStringList(
        _keyReadNotificationIds,
        ids.map((id) => id.toString()).toList(),
      );
    } catch (e) {
      debugPrint('LocalCacheService saveReadNotificationIds error: $e');
    }
  }

  static Future<Set<int>> getReadNotificationIds() async {
    try {
      final prefs = await _getPrefs();
      final list = prefs.getStringList(_keyReadNotificationIds);
      if (list != null) {
        return list.map((e) => int.tryParse(e) ?? 0).where((id) => id > 0).toSet();
      }
    } catch (e) {
      debugPrint('LocalCacheService getReadNotificationIds error: $e');
    }
    return <int>{};
  }

  // ==========================================
  // GENERAL CLEAR
  // ==========================================
  static Future<void> clearAllHistoryCache() async {
    try {
      final prefs = await _getPrefs();
      final keys =
          prefs.getKeys().where((k) => k.startsWith('cache_history_')).toList();
      for (final k in keys) {
        await prefs.remove(k);
      }
    } catch (e) {
      debugPrint('LocalCacheService clearHistory error: $e');
    }
  }
}
