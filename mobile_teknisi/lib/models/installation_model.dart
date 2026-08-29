class Installation {
  final int idInstallations;
  final int idProject;
  final int idUser;
  final String controllerCode;
  final String inputMethod;
  final int idLampType;
  final double? latitude;
  final double? longitude;
  final String address;

  Installation({
    required this.idInstallations,
    required this.idProject,
    required this.idUser,
    required this.controllerCode,
    required this.inputMethod,
    required this.idLampType,
    this.latitude,
    this.longitude,
    required this.address,
  });

  factory Installation.fromJson(
    Map<String, dynamic> json,
  ) {
    return Installation(
      idInstallations: int.parse(
        json['id_installations'].toString(),
      ),
      idProject: int.parse(
        json['id_project'].toString(),
      ),
      idUser: int.parse(
        json['id_user'].toString(),
      ),
      controllerCode:
          json['controller_code']?.toString() ?? '',
      inputMethod:
          json['input_method']?.toString() ?? '',
      idLampType: int.parse(
        json['id_lamp_type'].toString(),
      ),
      latitude: json['latitude'] != null
          ? double.tryParse(
              json['latitude'].toString(),
            )
          : null,
      longitude: json['longitude'] != null
          ? double.tryParse(
              json['longitude'].toString(),
            )
          : null,
      address:
          json['address']?.toString() ?? '',
    );
  }
}