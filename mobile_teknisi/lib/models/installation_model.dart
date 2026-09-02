class InstallationModel {
  final int idInstallation;
  final int idArea;
  final String lampCode;
  final String lampType;
  final String wattage;
  final String status;
  final String? photoUrl;
  final String? notes;

  InstallationModel({
    required this.idInstallation,
    required this.idArea,
    required this.lampCode,
    required this.lampType,
    required this.wattage,
    required this.status,
    this.photoUrl,
    this.notes,
  });

  factory InstallationModel.fromJson(Map<String, dynamic> json) {
    return InstallationModel(
      idInstallation: json['id_installation'] ?? 0,
      idArea: json['id_area'] ?? 0,
      lampCode: json['lamp_code'] ?? '',
      lampType: json['lamp_type'] ?? '',
      wattage: json['wattage'] ?? '',
      status: json['status'] ?? 'Terpasang',
      photoUrl: json['photo_url'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_installation': idInstallation,
      'id_area': idArea,
      'lamp_code': lampCode,
      'lamp_type': lampType,
      'wattage': wattage,
      'status': status,
      'photo_url': photoUrl,
      'notes': notes,
    };
  }
}
