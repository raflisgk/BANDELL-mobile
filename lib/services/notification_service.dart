import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import 'api_service.dart';
import 'auth_service.dart';

class NotificationService {
  /// Mengambil daftar notifikasi penugasan project dari Laravel API
  Future<List<NotificationModel>> getNotifications([int? userId]) async {
    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint('NotificationService: user_id tidak valid ($targetUserId)');
      return <NotificationModel>[];
    }

    try {
      final rawList = await ApiService.getNotifications(targetUserId);
      return rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationModel.fromJson(json))
          .toList();
    } catch (e) {
      debugPrint('NotificationService getNotifications error: $e');
      return <NotificationModel>[];
    }
  }

  /// Menandai notifikasi telah dibaca secara lokal (state)
  Future<bool> markAsRead(int idNotification) async {
    return true;
  }
}
