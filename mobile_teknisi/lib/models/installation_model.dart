class InstallationModel {
  final int idInstallation;
  final int? idProject;
  final int? idUser;
  final int idArea;
  final String lampCode;
  final String lampType;
  final String wattage;
  final String status;
  final String? latitude;
  final String? longitude;
  final String? panelCode;
  final List<String> photos;
  final String? inputMethod;
  final String? photoUrl;
  final String? notes;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InstallationModel({
    required this.idInstallation,
    this.idProject,
    this.idUser,
    required this.idArea,
    required this.lampCode,
    required this.lampType,
    this.wattage = '',
    this.status = 'Terpasang',
    this.latitude,
    this.longitude,
    this.panelCode,
    this.photos = const [],
    this.inputMethod,
    this.photoUrl,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  factory InstallationModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedPhotos = [];
    if (json['photos'] is List) {
      parsedPhotos = (json['photos'] as List).map((e) => e.toString()).toList();
    } else if (json['photo_url'] != null && json['photo_url'].toString().isNotEmpty) {
      parsedPhotos = [json['photo_url'].toString()];
    }

    return InstallationModel(
      idInstallation: json['id_installation'] is int
          ? json['id_installation']
          : int.tryParse(json['id_installation']?.toString() ?? '0') ?? 0,
      idProject: json['id_project'] != null
          ? (json['id_project'] is int
              ? json['id_project']
              : int.tryParse(json['id_project'].toString()))
          : null,
      idUser: json['id_user'] != null
          ? (json['id_user'] is int
              ? json['id_user']
              : int.tryParse(json['id_user'].toString()))
          : null,
      idArea: json['id_area'] is int
          ? json['id_area']
          : int.tryParse(json['id_area']?.toString() ?? '0') ?? 0,
      lampCode: json['lamp_code'] ?? json['kode_lampu'] ?? '',
      lampType: json['lamp_type'] ?? json['jenis_lampu'] ?? '',
      wattage: json['wattage'] ?? '',
      status: json['status'] ?? 'Terpasang',
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      panelCode: json['panel_code'] ?? json['kode_panel'],
      photos: parsedPhotos,
      inputMethod: json['input_method'] ?? json['metode_input'],
      photoUrl: json['photo_url'] ?? (parsedPhotos.isNotEmpty ? parsedPhotos.first : null),
      notes: json['notes'] ?? json['catatan'],
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_installation': idInstallation,
      'id_project': idProject,
      'id_user': idUser,
      'id_area': idArea,
      'lamp_code': lampCode,
      'lamp_type': lampType,
      'wattage': wattage,
      'status': status,
      'latitude': latitude,
      'longitude': longitude,
      'panel_code': panelCode,
      'photos': photos,
      'input_method': inputMethod,
      'photo_url': photoUrl,
      'notes': notes,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
