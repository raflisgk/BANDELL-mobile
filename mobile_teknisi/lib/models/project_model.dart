class Project {
  final int idProject;
  final String projectName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String status;

  Project({
    required this.idProject,
    required this.projectName,
    this.startDate,
    this.endDate,
    required this.status,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      idProject: int.parse(
        json['id_project'].toString(),
      ),
      projectName:
          json['project_name']?.toString() ?? '',
      startDate: json['start_date'] != null
          ? DateTime.tryParse(
              json['start_date'].toString(),
            )
          : null,
      endDate: json['end_date'] != null
          ? DateTime.tryParse(
              json['end_date'].toString(),
            )
          : null,
      status:
          json['status']?.toString() ?? '',
    );
  }
}