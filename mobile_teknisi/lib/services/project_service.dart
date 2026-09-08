import '../models/project_model.dart';

class ProjectService {
  /// Context project yang sedang dipilih secara global
  static Project? selectedProject;

  /// Cache list project yang tersedia dari API
  static List<Project> cachedProjects = [];

  /// Mengambil daftar project dari Laravel API
  Future<List<Project>> getProjects() async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/projects)
    await Future.delayed(const Duration(milliseconds: 200));
    return cachedProjects;
  }

  /// Mengambil detail project berdasarkan id
  Future<Project?> getProjectById(int id) async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/projects/{id})
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return cachedProjects.firstWhere((p) => p.idProject == id);
    } catch (_) {
      return null;
    }
  }

  /// List nama project untuk dropdown
  static List<String> get projectOptions =>
      cachedProjects.map((p) => p.projectName).toList();

  /// Mengambil project berdasarkan ID secara sinkron dari cache
  static Project? getProjectByIdSync(int id) {
    try {
      return cachedProjects.firstWhere((p) => p.idProject == id);
    } catch (_) {
      return null;
    }
  }

  /// Mengambil project berdasarkan nama
  static Project? getProjectByName(String name) {
    try {
      return cachedProjects.firstWhere((p) => p.projectName == name);
    } catch (_) {
      return null;
    }
  }
}

