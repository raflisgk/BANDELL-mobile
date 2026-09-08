import '../models/history_lamp_model.dart';
import '../models/installation_model.dart';

class InstallationService {
  /// Menyimpan data pendataan lampu baru (Realtime / Manual) ke Laravel API
  Future<InstallationModel> createInstallation(
      InstallationModel installation) async {
    // Siap diganti dengan HTTP POST request multipart/form-data ke Laravel API (/installations)
    return installation;
  }

  /// Mengambil detail record lampu berdasarkan ID dari Laravel API
  Future<InstallationModel?> getInstallationDetail(int idInstallation) async {
    // Siap diganti dengan HTTP GET request ke Laravel API (/installations/{id})
    return null;
  }

  /// Mengubah data lampu berdasarkan ID ke Laravel API
  Future<InstallationModel> updateInstallation(
    int idInstallation,
    InstallationModel installation,
  ) async {
    // Siap diganti dengan HTTP PUT/POST request ke Laravel API (/installations/{id})
    return installation;
  }

  /// Menghapus data lampu berdasarkan ID dari Laravel API
  Future<bool> deleteInstallation(int idInstallation) async {
    // Siap diganti dengan HTTP DELETE request ke Laravel API (/installations/{id})
    return true;
  }

  /// Mengambil riwayat pendataan lampu berdasarkan user dan project
  Future<List<HistoryLampModel>> getHistory({
    required int userId,
    required int projectId,
    String? filter,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    // Siap diganti dengan HTTP GET request ke Laravel API (/installations/history)
    return <HistoryLampModel>[];
  }
}

