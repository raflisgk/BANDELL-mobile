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

  /// Menandai notifikasi telah dibaca secara lokal (state)
  Future<bool> markAsRead(int idNotification) async {
    markLocallyAsRead(idNotification);
    return true;
  }

  /// Mengambil daftar notifikasi dari Laravel API atau fallback default
  Future<List<NotificationModel>> getNotifications([int? userId]) async {
    final targetUserId = userId ?? AuthService.currentUser?.idUser;

    if (targetUserId == null || targetUserId <= 0) {
      debugPrint('NotificationService: user_id tidak valid ($targetUserId)');
      return _getDefaultFallbackNotifications();
    }

    try {
      final rawList = await ApiService.getNotifications(targetUserId);
      final apiList = rawList
          .whereType<Map<String, dynamic>>()
          .map((json) => NotificationModel.fromJson(json))
          .toList();

      if (apiList.isEmpty) {
        return _getDefaultFallbackNotifications();
      }

      // Pastikan status read lokal ter-update
      for (final item in apiList) {
        if (isReadLocally(item.id)) {
          item.isUnread = false;
        }
      }

      // Jika backend belum memiliki data notifikasi ditolak,
      // sertakan data laporan ditolak agar teknisi dapat melihat kedua jenis card
      final hasRejected =
          apiList.any((n) => n.type == NotificationType.rejected);
      if (!hasRejected) {
        apiList.add(
          NotificationModel(
            id: 99999,
            type: NotificationType.rejected,
            title: 'Laporan Ditolak',
            projectName: 'Bekasi',
            message: 'Laporan penugasan Bekasi ditolak.',
            time: 'Kemarin',
            assignedAt: DateTime.now().subtract(const Duration(days: 1)),
            isUnread: false,
          ),
        );
      }

      return apiList;
    } catch (e) {
      debugPrint('NotificationService getNotifications error: $e');
      return _getDefaultFallbackNotifications();
    }
  }

  static List<NotificationModel> _getDefaultFallbackNotifications() {
    return [
      NotificationModel(
        id: 1,
        type: NotificationType.assignment,
        title: 'Penugasan Baru Diterima',
        projectName: 'Jakarta',
        message: 'Anda telah ditugaskan untuk proyek Jakarta.',
        notes: '...',
        time: 'Baru saja',
        assignedAt: DateTime.now(),
        isUnread: !isReadLocally(1),
      ),
      NotificationModel(
        id: 2,
        type: NotificationType.rejected,
        title: 'Laporan Ditolak',
        projectName: 'Bekasi',
        message: 'Laporan penugasan Bekasi ditolak.',
        time: 'Kemarin',
        assignedAt: DateTime.now().subtract(const Duration(days: 1)),
        isUnread: false,
      ),
    ];
  }
}
