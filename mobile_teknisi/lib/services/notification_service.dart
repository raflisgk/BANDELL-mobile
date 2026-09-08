import '../models/notification_model.dart';

class NotificationService {
  /// Mengambil daftar notifikasi pengguna dari Laravel API
  Future<List<NotificationModel>> getNotifications() async {
    // Siap diganti dengan HTTP GET request ke Laravel API (/notifications)
    return <NotificationModel>[];
  }

  /// Menandai notifikasi telah dibaca ke Laravel API
  Future<bool> markAsRead(int idNotification) async {
    // Siap diganti dengan HTTP POST request ke Laravel API (/notifications/{id}/read)
    await Future.delayed(const Duration(milliseconds: 200));
    return true;
  }
}
