class InstallationModel {
  final int idInstallation;
  final int? idProject;
  final int? idUser;
  final int idArea;

  // ID jenis lampu untuk database
  final int? lampTypeId;

  // Nama jenis lampu untuk tampilan
  final String lampType;

  final String? idLcu;
  final String lampCode;
  final String wattage;
  final String status;
  final String? districtName;
  final String? latitude;
  final String? longitude;
  final String? panelCode;
  final List<String> photos;
  final String? inputMethod;
  final String? photoUrl;
  final String? notes;
  final DateTime? installedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  InstallationModel({
    required this.idInstallation,
    this.idProject,
    this.idUser,
    required this.idArea,
    this.districtName,
    this.lampTypeId,
    this.idLcu,
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
    this.installedAt,
    this.createdAt,
    this.updatedAt,
  });

  String? get id => idInstallation.toString();

  String? get lampId => lampCode;

  String? get areaId => idArea.toString();

  String? get projectId => idProject?.toString();

  factory InstallationModel.fromJson(Map<String, dynamic> json) {
    List<String> parsedPhotos = [];

    if (json['photos'] is List) {
      parsedPhotos = (json['photos'] as List).map((e) {
        if (e is Map) {
          final path = e['photo_path'] ?? e['url'] ?? e['path'];
          if (path != null) return path.toString();
        }
        return e.toString();
      }).toList();
    } else if (json['photo_url'] != null &&
        json['photo_url'].toString().isNotEmpty) {
      parsedPhotos = [json['photo_url'].toString()];
    }

    int? parseInt(dynamic value) {
      if (value == null) return null;

      if (value is int) {
        return value;
      }

      return int.tryParse(value.toString());
    }

    String lampTypeName = '';

    if (json['lamp_type'] is Map) {
      lampTypeName =
          json['lamp_type']['lamp_name']?.toString() ??
          json['lamp_type']['name']?.toString() ??
          '';
    } else {
      lampTypeName =
          json['lamp_type']?.toString() ??
          json['jenis_lampu']?.toString() ??
          '';
    }
    final rawLcu = json['id_lcu']?.toString() ??
        json['idLcu']?.toString() ??
        json['lamp_code']?.toString() ??
        json['kode_lampu']?.toString() ??
        json['id_barcode']?.toString();

    return InstallationModel(
      idInstallation: json['id_installation'] is int
          ? json['id_installation']
          : int.tryParse(
                json['id_installation']?.toString() ??
                    json['id']?.toString() ??
                    '0',
              ) ??
              0,

      idProject: parseInt(
        json['id_project'] ?? json['project_id'],
      ),

      idUser: parseInt(
        json['id_user'] ?? json['user_id'],
      ),

      idArea: parseInt(
            json['id_area'] ??
                json['area_id'] ??
                json['district_id'],
          ) ??
          0,

      districtName: (() {
        if (json['district'] is Map) {
          return json['district']['name']?.toString() ??
              json['district']['district_name']?.toString();
        }
        return json['district_name']?.toString() ??
            json['area_name']?.toString();
      })(),

      // ID jenis lampu dari database
      lampTypeId: parseInt(
        json['lamp_type_id'] ??
            json['id_lamp_type'],
      ),

      idLcu: json['id_lcu']?.toString() ?? rawLcu,
      lampCode: rawLcu ?? '',
      lampType: lampTypeName,

      wattage: json['wattage']?.toString() ?? '',

      status:
          json['status']?.toString() ??
          json['verification_status']?.toString() ??
          'Terpasang',

      latitude: json['latitude']?.toString(),

      longitude: json['longitude']?.toString(),

      panelCode:
          json['panel_code']?.toString() ??
          json['kode_panel']?.toString() ??
          json['code_panel']?.toString(),

      photos: parsedPhotos,

      inputMethod: (() {
    final value = json['input_method'] ??
      json['metode_input'] ??
      json['inputMethod'];

    if (value == null) return null;

    final method = value.toString().trim().toLowerCase();

    if (method == 'realtime' || method == 'real-time') {
    return 'Realtime';
    }

    if (method == 'manual') {
    return 'Manual';
    }

  return value.toString();
})(),

      photoUrl:
          json['photo_url']?.toString() ??
          (parsedPhotos.isNotEmpty ? parsedPhotos.first : null),

      notes:
          json['notes']?.toString() ??
          json['catatan']?.toString(),

      installedAt: json['installed_at'] != null
          ? DateTime.tryParse(
              json['installed_at'].toString(),
            )
          : null,

      createdAt: json['created_at'] != null
          ? DateTime.tryParse(
              json['created_at'].toString(),
            )
          : null,

      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(
              json['updated_at'].toString(),
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_installation': idInstallation,
      'id_project': idProject,
      'id_user': idUser,
      'id_area': idArea,

      // ID yang dikirim ke backend
      'lamp_type_id': lampTypeId,

      'id_lcu': idLcu ?? lampCode,
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
      'installed_at': installedAt?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}