import '../dummy/dummy_data.dart';
import '../models/history_lamp_model.dart';
import '../models/installation_model.dart';

class InstallationService {
  /// Menyimpan data pendataan lampu baru (Realtime / Manual) ke Laravel API
  Future<InstallationModel> createInstallation(
      InstallationModel installation) async {
    // Siap diganti dengan HTTP POST request multipart/form-data ke Laravel API (/installations)
    await Future.delayed(const Duration(milliseconds: 600));
    return installation;
  }

  /// Mengambil detail record lampu berdasarkan ID dari Laravel API
  Future<InstallationModel?> getInstallationDetail(int idInstallation) async {
    // Siap diganti dengan HTTP GET request ke Laravel API (/installations/{id})
    await Future.delayed(const Duration(milliseconds: 300));
    return InstallationModel(
      idInstallation: idInstallation,
      idArea: 101,
      lampCode: 'JKT-2025-001',
      lampType: 'LED 90W',
      wattage: '90W',
      status: 'Tersimpan',
      latitude: '-7.051234',
      longitude: '110.439812',
      panelCode: 'PNL-001',
      inputMethod: 'Realtime',
      createdAt: DateTime.now().subtract(const Duration(days: 1)),
      updatedAt: DateTime.now(),
    );
  }

  /// Mengubah data lampu berdasarkan ID ke Laravel API
  Future<InstallationModel> updateInstallation(
    int idInstallation,
    InstallationModel installation,
  ) async {
    // Siap diganti dengan HTTP PUT/POST request ke Laravel API (/installations/{id})
    await Future.delayed(const Duration(milliseconds: 600));
    return installation;
  }

  /// Menghapus data lampu berdasarkan ID dari Laravel API
  Future<bool> deleteInstallation(int idInstallation) async {
    // Siap diganti dengan HTTP DELETE request ke Laravel API (/installations/{id})
    await Future.delayed(const Duration(milliseconds: 400));
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
    await Future.delayed(const Duration(milliseconds: 400));
    final dummyList = DummyData.getHistoryByUserAndProject(
      userId: userId,
      projectId: projectId,
    );

    return dummyList
        .map((item) => HistoryLampModel(
              idHistory: item.idHistory,
              userId: item.userId,
              projectId: item.projectId,
              areaId: item.areaId,
              kode: item.kode,
              jenis: item.jenis,
              status: item.status,
              isVerified: item.isVerified,
              lokasi: item.lokasi,
              koordinat: item.koordinat,
              fotoCount: item.fotoCount,
              waktu: item.waktu,
              tanggal: item.tanggal,
            ))
        .toList();
  }
}
