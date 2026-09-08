class HistoryLampModel {
  final int? idHistory;
  final int userId;
  final int projectId;
  final int? areaId;
  final String kode;
  final String jenis;
  final String status;
  final bool isVerified;
  final String lokasi;
  final String koordinat;
  final String fotoCount;
  final String waktu;
  final DateTime? tanggal;

  const HistoryLampModel({
    this.idHistory,
    required this.userId,
    required this.projectId,
    this.areaId,
    required this.kode,
    required this.jenis,
    required this.status,
    required this.isVerified,
    required this.lokasi,
    required this.koordinat,
    required this.fotoCount,
    required this.waktu,
    this.tanggal,
  });

  factory HistoryLampModel.fromJson(Map<String, dynamic> json) {
    return HistoryLampModel(
      idHistory: json['id_history'] is int
          ? json['id_history']
          : int.tryParse(json['id_history']?.toString() ?? ''),
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      projectId: json['project_id'] is int
          ? json['project_id']
          : int.tryParse(json['project_id']?.toString() ?? '0') ?? 0,
      areaId: json['area_id'] != null
          ? (json['area_id'] is int
              ? json['area_id']
              : int.tryParse(json['area_id'].toString()))
          : null,
      kode: json['kode'] ?? json['lamp_code'] ?? '',
      jenis: json['jenis'] ?? json['lamp_type'] ?? '',
      status: json['status'] ?? 'Tersimpan',
      isVerified: json['is_verified'] == true ||
          json['is_verified'] == 1 ||
          json['is_verified'] == '1',
      lokasi: json['lokasi'] ?? json['address'] ?? json['location'] ?? '',
      koordinat: json['koordinat'] ??
          (json['latitude'] != null && json['longitude'] != null
              ? '${json['latitude']}, ${json['longitude']}'
              : ''),
      fotoCount: json['foto_count'] ??
          (json['photos'] is List
              ? '${(json['photos'] as List).length} Foto Lampu'
              : '0 Foto Lampu'),
      waktu: json['waktu'] ?? '',
      tanggal: json['tanggal'] != null
          ? DateTime.tryParse(json['tanggal'].toString())
          : (json['created_at'] != null
              ? DateTime.tryParse(json['created_at'].toString())
              : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_history': idHistory,
      'user_id': userId,
      'project_id': projectId,
      'area_id': areaId,
      'kode': kode,
      'jenis': jenis,
      'status': status,
      'is_verified': isVerified,
      'lokasi': lokasi,
      'koordinat': koordinat,
      'foto_count': fotoCount,
      'waktu': waktu,
      'tanggal': tanggal?.toIso8601String(),
    };
  }
}
