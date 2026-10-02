import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import 'api_service.dart';
import 'auth_service.dart';
import 'local_cache_service.dart';

class NotificationService {
  static Set<int> _readNotificationIds = <int>{};

  /// Bersihkan cache notifikasi
  static void clearCache() {
    _readNotificationIds.clear();
  }

  /// Mengecek apakah notifikasi sudah dibaca secara lokal
  static bool isReadLocally(int id) => _readNotificationIds.contains(id);

  /// Menandai notifikasi telah dibaca secara lokal
  static Future<void> markLocallyAsRead(int id) async {
    _readNotificationIds.add(id);
    await LocalCacheService.saveReadNotificationIds(_readNotificationIds);
  }

  /// Menandai notifikasi telah dibaca secara lokal dan database API
  Future<bool> markAsRead(int idNotification) async {
    await markLocallyAsRead(idNotification);
    try {
      await ApiService.markNotificationAsRead(idNotification);
    } catch (e) {
      debugPrint('NotificationService markAsRead API error: $e');
    }
    return true;
  }

  /// Mengambil daftar notifikasi dari Laravel API atau Storage HP
  Future<List<NotificationModel>> getNotifications({
    int? userId,
    bool forceRefresh = false,
  }) async {
    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint('NotificationService: user_id tidak valid ($targetUserId)');
      return [];
    }

    // Ambil read IDs dari Storage HP jika belum terisi
    if (_readNotificationIds.isEmpty) {
      _readNotificationIds = await LocalCacheService.getReadNotificationIds();
    }

    if (!forceRefresh) {
      final cachedJson = await LocalCacheService.getNotificationsJson(targetUserId);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return cachedJson
            .whereType<Map<String, dynamic>>()
            .map((json) {
              final model = NotificationModel.fromJson(json);
              if (isReadLocally(model.id)) {
                model.isUnread = false;
              }
              return model;
            })
            .toList();
      }
    }

    try {
      final rawList = await ApiService.getNotifications(targetUserId);
      await LocalCacheService.saveNotificationsJson(targetUserId, rawList);

      final apiList = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      for (final item in apiList) {
        if (isReadLocally(item.id)) {
          item.isUnread = false;
        }
      }

      return apiList;
    } catch (e) {
      debugPrint('NotificationService getNotifications error: $e. Using Storage HP.');
      final cachedJson = await LocalCacheService.getNotificationsJson(targetUserId);
      if (cachedJson != null && cachedJson.isNotEmpty) {
        return cachedJson
            .whereType<Map<String, dynamic>>()
            .map((json) {
              final model = NotificationModel.fromJson(json);
              if (isReadLocally(model.id)) {
                model.isUnread = false;
              }
              return model;
            })
            .toList();
      }
      rethrow;
    }
  }
}
