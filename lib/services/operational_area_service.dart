import '../models/area_model.dart';

class OperationalAreaService {
  /// Mengambil daftar Area Operasional berdasarkan ID Project dari Laravel API
  Future<List<AreaModel>> getAreasByProjectId(int projectId) async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/projects/{id}/areas)
    await Future.delayed(const Duration(milliseconds: 200));
    return [];
  }
}
