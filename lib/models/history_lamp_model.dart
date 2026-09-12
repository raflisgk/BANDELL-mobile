import 'package:flutter/foundation.dart';
import 'installation_model.dart';

class HistoryLampModel {
  final int? idHistory;
  final int userId;
  final int projectId;
  final int? areaId;
  final String? districtName;
  final String kode;
  final String jenis;
  final String status;
  final bool isVerified;
  final String lokasi;
  final String koordinat;
  final String? latitude;
  final String? longitude;
  final String fotoCount;
  final String waktu;
  final DateTime? tanggal;
  final DateTime? installedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? inputMethod;
  final String? panelCode;
  final String? idLcu;
  final InstallationModel? installation;

  const HistoryLampModel({
    this.idHistory,
    required this.userId,
    required this.projectId,
    this.areaId,
    this.districtName,
    required this.kode,
    required this.jenis,
    required this.status,
    required this.isVerified,
    required this.lokasi,
    required this.koordinat,
    this.latitude,
    this.longitude,
    required this.fotoCount,
    required this.waktu,
    this.tanggal,
    this.installedAt,
    this.createdAt,
    this.updatedAt,
    this.inputMethod,
    this.panelCode,
    this.idLcu,
    this.installation,
  });

  factory HistoryLampModel.fromJson(Map<String, dynamic> json) {
    String lampTypeName = '';
    if (json['lamp_type'] is Map) {
      lampTypeName = json['lamp_type']['lamp_name']?.toString() ??
          json['lamp_type']['name']?.toString() ??
          '';
    } else if (json['lampType'] is Map) {
      lampTypeName = json['lampType']['lamp_name']?.toString() ??
          json['lampType']['name']?.toString() ??
          '';
    } else {
      lampTypeName = json['jenis']?.toString() ??
          json['lamp_type']?.toString() ??
          '';
    }

    final rawId = json['id_history'] ?? json['id'];
    final parsedId = rawId is int
        ? rawId
        : int.tryParse(rawId?.toString() ?? '');

    final rawAreaId = json['area_id'] ?? json['district_id'];
    final parsedAreaId = rawAreaId is int
        ? rawAreaId
        : int.tryParse(rawAreaId?.toString() ?? '');

    final vStatus = json['verification_status']?.toString() ??
        json['status']?.toString() ??
        'Tersimpan';

    final isVerif = json['is_verified'] == true ||
        json['is_verified'] == 1 ||
        json['is_verified'] == '1' ||
        vStatus.toLowerCase() == 'terverifikasi';

    InstallationModel? instModel;
    try {
      instModel = InstallationModel.fromJson(json);
    } catch (_) {}

    final installedAt = json['installed_at'] != null
        ? DateTime.tryParse(json['installed_at'].toString())
        : instModel?.installedAt;

    final createdAt = instModel?.createdAt ??
        (json['created_at'] != null
            ? DateTime.tryParse(json['created_at'].toString())
            : null);

    final updatedAt = instModel?.updatedAt ??
        (json['updated_at'] != null
            ? DateTime.tryParse(json['updated_at'].toString())
            : null);

    debugPrint('HISTORY installed_at API: ${json['installed_at']}');
    debugPrint('HISTORY installedAt MODEL: $installedAt');
    debugPrint('HISTORY created_at API: ${json['created_at']}');
    debugPrint('HISTORY createdAt MODEL: $createdAt');

    // Tanggal instalasi utama adalah installed_at. JANGAN gunakan updated_at atau created_at!
    final effectiveTanggal = installedAt ??
        (json['tanggal'] != null
            ? DateTime.tryParse(json['tanggal'].toString())
            : null);

    final waktuStr = json['installed_at']?.toString() ??
        installedAt?.toIso8601String() ??
        createdAt?.toIso8601String() ??
        json['created_at']?.toString() ??
        json['waktu']?.toString() ??
        '';

    final rawInput = json['input_method'] ??
        json['metode_input'] ??
        json['inputMethod'] ??
        instModel?.inputMethod;

    String? normInput;
    if (rawInput != null) {
      final s = rawInput.toString().trim();
      final l = s.toLowerCase();
      if (l == 'realtime' || l == 'real-time') {
        normInput = 'Realtime';
      } else if (l == 'manual') {
        normInput = 'Manual';
      } else if (s.isNotEmpty && s != '-') {
        normInput = s;
      }
    }

    final pCode = json['code_panel']?.toString() ??
        json['panel_code']?.toString() ??
        json['kode_panel']?.toString() ??
        instModel?.panelCode;

    final rawLcu = json['id_lcu']?.toString() ??
        json['idLcu']?.toString() ??
        json['kode']?.toString() ??
        json['lamp_code']?.toString() ??
        json['kode_lampu']?.toString() ??
        json['id_barcode']?.toString() ??
        instModel?.idLcu ??
        instModel?.lampCode;

    final lat = json['latitude']?.toString() ?? instModel?.latitude;
    final lng = json['longitude']?.toString() ?? instModel?.longitude;

    String? distName;
    if (json['district'] is Map) {
      distName = json['district']['name']?.toString() ??
          json['district']['district_name']?.toString();
    } else if (json['district_name'] != null) {
      distName = json['district_name']?.toString();
    } else if (json['area_name'] != null) {
      distName = json['area_name']?.toString();
    } else if (instModel?.districtName != null) {
      distName = instModel!.districtName;
    }

    return HistoryLampModel(
      idHistory: parsedId,
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      areaId: parsedAreaId,
      districtName: distName,
      idLcu: json['id_lcu']?.toString() ?? rawLcu,
      kode: rawLcu ?? '',
      jenis: lampTypeName,
      status: vStatus,
      isVerified: isVerif,
      lokasi: json['lokasi']?.toString() ??
          json['address']?.toString() ??
          json['location']?.toString() ??
          '',
      koordinat: json['koordinat']?.toString() ??
          (lat != null && lng != null && lat.isNotEmpty && lng.isNotEmpty
              ? '$lat, $lng'
              : ''),
      latitude: lat,
      longitude: lng,
      fotoCount: json['foto_count']?.toString() ??
          (json['photos'] is List
              ? '${(json['photos'] as List).length} Foto Lampu'
              : '0 Foto Lampu'),
      waktu: waktuStr,
      tanggal: effectiveTanggal,
      installedAt: installedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
      inputMethod: normInput,
      panelCode: pCode,
      installation: instModel,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_history': idHistory,
      'user_id': userId,
      'project_id': projectId,
      'area_id': areaId,
      'district_name': districtName,
      'latitude': latitude,
      'longitude': longitude,
      'id_lcu': idLcu ?? kode,
      'kode': kode,
      'jenis': jenis,
      'status': status,
      'is_verified': isVerified,
      'lokasi': lokasi,
      'koordinat': koordinat,
      'foto_count': fotoCount,
      'waktu': waktu,
      'tanggal': tanggal?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'input_method': inputMethod,
      'panel_code': panelCode,
    };
  }
}
