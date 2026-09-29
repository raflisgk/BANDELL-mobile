import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NotificationService {
  static final Set<int> _readNotificationIds = <int>{};
  static List<NotificationModel> _cachedNotifications = [];

  /// Cek apakah ada notifikasi di memori cache
  static bool get hasCache => _cachedNotifications.isNotEmpty;

  /// Ambil daftar notifikasi dari cache
  static List<NotificationModel> get cachedNotifications =>
      _cachedNotifications;

  /// Bersihkan seluruh cache notifikasi
  static void clearCache() {
    _cachedNotifications.clear();
    _readNotificationIds.clear();
  }

  /// Mengecek apakah notifikasi sudah dibaca secara lokal
  static bool isReadLocally(int id) => _readNotificationIds.contains(id);

  /// Menandai notifikasi telah dibaca secara lokal
  static void markLocallyAsRead(int id) {
    _readNotificationIds.add(id);
    for (final notif in _cachedNotifications) {
      if (notif.id == id) {
        notif.isUnread = false;
      }
    }
  }

  /// Menandai notifikasi telah dibaca secara lokal dan database API
  Future<bool> markAsRead(int idNotification) async {
    markLocallyAsRead(idNotification);
    try {
      await ApiService.markNotificationAsRead(idNotification);
    } catch (e) {
      debugPrint('NotificationService markAsRead API error: $e');
    }
    return true;
  }

  /// Mengambil daftar notifikasi dari Laravel API atau cache
  Future<List<NotificationModel>> getNotifications({
    int? userId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedNotifications.isNotEmpty) {
      return _cachedNotifications;
    }

    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint('NotificationService: user_id tidak valid ($targetUserId)');
      return _cachedNotifications;
    }

    try {
      final rawList = await ApiService.getNotifications(targetUserId);
      final apiList = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      // Pastikan status read lokal ter-update
      for (final item in apiList) {
        if (isReadLocally(item.id)) {
          item.isUnread = false;
        }
      }

      _cachedNotifications = apiList;
      return apiList;
    } catch (e) {
      debugPrint('NotificationService getNotifications error: $e');
      if (_cachedNotifications.isNotEmpty) {
        return _cachedNotifications;
      }
      rethrow;
    }
  }
}
