import '../dummy/dummy_data.dart';
import '../models/notification_model.dart';

class NotificationService {
  /// Mengambil daftar notifikasi pengguna dari Laravel API
  Future<List<NotificationModel>> getNotifications() async {
    // Siap diganti dengan HTTP GET request ke Laravel API (/notifications)
    await Future.delayed(const Duration(milliseconds: 300));
    return DummyData.notifications
        .map((n) => NotificationModel(
              id: n.id,
              title: n.title,
              content: n.content,
              time: n.time,
              isUnread: n.isUnread,
              boldText: n.boldText,
            ))
        .toList();
  }

  /// Menandai notifikasi telah dibaca ke Laravel API
  Future<bool> markAsRead(int idNotification) async {
    // Siap diganti dengan HTTP POST request ke Laravel API (/notifications/{id}/read)
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
