import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NotificationService {
  static final Set<int> _readNotificationIds = <int>{};

  /// Mengecek apakah notifikasi sudah dibaca secara lokal
  static bool isReadLocally(int id) => _readNotificationIds.contains(id);

  /// Menandai notifikasi telah dibaca secara lokal
  static void markLocallyAsRead(int id) {
    _readNotificationIds.add(id);
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

  /// Mengambil daftar notifikasi murni dari Laravel API
  Future<List<NotificationModel>> getNotifications([int? userId]) async {
    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint('NotificationService: user_id tidak valid ($targetUserId)');
      return [];
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

      return apiList;
    } catch (e) {
      debugPrint('NotificationService getNotifications error: $e');
      rethrow;
    }
  }
}
