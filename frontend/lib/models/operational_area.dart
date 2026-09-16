class OperationalArea {
  final int idOperationalArea;
  final int idProject;
  final String areaName;

  OperationalArea({
    required this.idOperationalArea,
    required this.idProject,
    required this.areaName,
  });

  factory OperationalArea.fromJson(Map<String, dynamic> json) {
    return OperationalArea(
      idOperationalArea: json['id_operational_area'] ?? 0,
      idProject: json['id_project'] ?? 0,
      areaName: json['area_name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_operational_area': idOperationalArea,
      'id_project': idProject,
      'area_name': areaName,
    };
  }
}
