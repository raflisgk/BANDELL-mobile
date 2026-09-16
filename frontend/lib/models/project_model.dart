class ProjectModel {
  final int id;
  final String name;
  final String status;
  final String? description;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;

  ProjectModel({
    required this.id,
    required this.name,
    this.status = 'aktif',
    this.description,
    this.location,
    this.startDate,
    this.endDate,
  });

  // Compatibility getters for legacy code
  int get idProject => id;
  String get projectName => name;

  bool get isActive =>
      status.toLowerCase() == 'aktif' || status.toLowerCase() == 'active';

  bool get isCompleted =>
      status.toLowerCase() == 'selesai' ||
      status.toLowerCase() == 'closed' ||
      status.toLowerCase() == 'completed';

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'] ?? json['id_project'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '0') ?? 0;

    return ProjectModel(
      id: parsedId,
      name: json['name']?.toString() ?? json['project_name']?.toString() ?? '',
      status: json['status']?.toString() ?? 'aktif',
      description: json['description']?.toString(),
      location: json['location']?.toString() ?? json['lokasi']?.toString(),
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status,
      'description': description,
      'id_project': id,
      'project_name': name,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
    };
  }
}

typedef Project = ProjectModel;
