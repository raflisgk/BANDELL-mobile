class AreaModel {
  final int idArea;
  final int idProject;
  final String areaName;
  final int totalLamps;
  final String? assignedAt;
  final String status;

  AreaModel({
    required this.idArea,
    required this.idProject,
    required this.areaName,
    this.totalLamps = 0,
    this.assignedAt,
    this.status = 'aktif',
  });

  String get id => idArea.toString();
  String get projectId => idProject.toString();
  String get name => areaName;
  bool get isActive => status.toLowerCase() != 'nonaktif';
  bool get isNonaktif => status.toLowerCase() == 'nonaktif';

  /// Returns formatted assigned_at string as 'yyyy-MM-dd HH:mm:ss' or '-' if null/empty
  static String formatAssignedAt(String? raw) {
    if (raw == null ||
        raw.trim().isEmpty ||
        raw.trim() == '-' ||
        raw.trim().toLowerCase() == 'null') {
      return '-';
    }
    final trimmed = raw.trim();
    if (trimmed.contains('T')) {
      final dt = DateTime.tryParse(trimmed);
      if (dt != null) {
        final year = dt.year.toString().padLeft(4, '0');
        final month = dt.month.toString().padLeft(2, '0');
        final day = dt.day.toString().padLeft(2, '0');
        final hour = dt.hour.toString().padLeft(2, '0');
        final minute = dt.minute.toString().padLeft(2, '0');
        final second = dt.second.toString().padLeft(2, '0');
        return '$year-$month-$day $hour:$minute:$second';
      }
    }
    return trimmed;
  }

  String get displayAssignedAt => formatAssignedAt(assignedAt);

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      idArea: json['id_area'] is int
          ? json['id_area']
          : int.tryParse(json['id_area']?.toString() ?? json['id']?.toString() ?? '0') ?? 0,
      idProject: json['id_project'] is int
          ? json['id_project']
          : int.tryParse(json['id_project']?.toString() ?? json['project_id']?.toString() ?? '0') ?? 0,
      areaName: json['area_name'] ?? json['name'] ?? '',
      totalLamps: json['total_lamps'] ?? 0,
      assignedAt: json['assigned_at']?.toString(),
      status: json['status']?.toString() ?? 'aktif',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_area': idArea,
      'id_project': idProject,
      'area_name': areaName,
      'total_lamps': totalLamps,
      'assigned_at': assignedAt,
      'status': status,
    };
  }
}
