class Project {
  final int idProject;
  final String projectName;
  final String? location;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Project({
    required this.idProject,
    required this.projectName,
    this.location,
    this.startDate,
    this.endDate,
    this.status = 'active',
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      idProject: json['id_project'] is int
          ? json['id_project']
          : int.tryParse(json['id_project']?.toString() ?? '0') ?? 0,
      projectName: json['project_name'] ?? json['name'] ?? '',
      location: json['location'] ?? json['lokasi'],
      startDate: json['start_date'] != null
          ? DateTime.tryParse(json['start_date'].toString())
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(json['end_date'].toString())
          : null,
      status: json['status'] ?? 'active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_project': idProject,
      'project_name': projectName,
      'location': location,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'status': status,
    };
  }
}
