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

  bool get isActive => status.toLowerCase() != 'nonaktif';

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
