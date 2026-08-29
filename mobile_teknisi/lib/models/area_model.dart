class OperationalArea {
  final int idOperationalArea;
  final int idProject;
  final String areaName;
  final String location;
  final String status;

  OperationalArea({
    required this.idOperationalArea,
    required this.idProject,
    required this.areaName,
    required this.location,
    required this.status,
  });

  factory OperationalArea.fromJson(
    Map<String, dynamic> json,
  ) {
    return OperationalArea(
      idOperationalArea: int.parse(
        json['id_operational_area'].toString(),
      ),
      idProject: int.parse(
        json['id_project'].toString(),
      ),
      areaName:
          json['area_name']?.toString() ?? '',
      location:
          json['location']?.toString() ?? '',
      status:
          json['status']?.toString() ?? '',
    );
  }
}