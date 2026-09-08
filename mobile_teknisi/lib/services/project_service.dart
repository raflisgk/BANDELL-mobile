import '../dummy/dummy_data.dart';
import '../models/project_model.dart';

class ProjectService {
  /// Mengambil daftar semua project (aktif & selesai) dari Laravel API
  Future<List<Project>> getProjects() async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/projects)
    await Future.delayed(const Duration(milliseconds: 400));
    return DummyData.sortedProjects;
  }

  /// Mengambil detail project berdasarkan id
  Future<Project?> getProjectById(int id) async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/projects/{id})
    await Future.delayed(const Duration(milliseconds: 200));
    return DummyData.getProjectById(id);
  }
}
