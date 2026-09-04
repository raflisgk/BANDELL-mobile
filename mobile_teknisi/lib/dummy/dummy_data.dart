import 'package:flutter/material.dart';
import '../models/area_model.dart';
import '../models/project_model.dart';
import '../models/user_model.dart';
import '../screens/history/history_lamp_card.dart';
import '../screens/lamp/lamp_page.dart';
import '../screens/notification/notification_page.dart';

class DummyDataConfig {
  /// Toggle this flag to true to show dummy testing data, or false to revert to empty/API state.
  static const bool useDummyData = true;
}

class DummyData {
  // Users (Teknisi)
  static final List<UserModel> users = [
    UserModel(
      idUser: 1,
      username: 'teknisi_a',
      name: 'Teknisi A',
      role: 'teknisi',
    ),
    UserModel(
      idUser: 2,
      username: 'teknisi_b',
      name: 'Teknisi B',
      role: 'teknisi',
    ),
  ];

  /// Context User yang sedang login saat ini (Default: User A, id: 1)
  static UserModel currentUser = users[0];

  /// Context Project yang sedang dipilih secara global dalam aplikasi
  static Project? selectedProject;

  /// Helper untuk mengganti user login saat testing
  static void switchUser(int userId) {
    try {
      currentUser = users.firstWhere((u) => u.idUser == userId);
    } catch (_) {}
  }

  // Projects (Aktif dan Selesai)
  static final List<Project> projects = [
    // --- Project AKTIF (Berada paling atas) ---
    Project(
      idProject: 1,
      projectName: 'PJU Kota Semarang 2026',
      location: 'Kota Semarang, Jawa Tengah',
      startDate: DateTime(2026, 1, 1),
      endDate: DateTime(2026, 12, 31),
      status: 'active',
    ),
    Project(
      idProject: 2,
      projectName: 'PJU Kecamatan Banyumanik',
      location: 'Kecamatan Banyumanik, Semarang',
      startDate: DateTime(2026, 2, 1),
      endDate: DateTime(2026, 11, 30),
      status: 'active',
    ),
    Project(
      idProject: 3,
      projectName: 'PJU Kecamatan Tembalang',
      location: 'Kecamatan Tembalang, Semarang',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 10, 31),
      status: 'active',
    ),

    // --- Project SELESAI (Berada paling bawah) ---
    Project(
      idProject: 4,
      projectName: 'PJU Kota Semarang 2025',
      location: 'Kota Semarang, Jawa Tengah',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 12, 31),
      status: 'closed',
    ),
    Project(
      idProject: 5,
      projectName: 'PJU Semarang Barat 2025',
      location: 'Semarang Barat, Jawa Tengah',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 12, 31),
      status: 'closed',
    ),
  ];

  /// Urutan Project di Dropdown: Semua Project AKTIF berada paling atas, semua Project SELESAI berada paling bawah
  static List<Project> get sortedProjects {
    final active = projects
        .where((p) => p.status == 'active' || p.status == 'aktif')
        .toList();
    final closed = projects
        .where((p) => p.status != 'active' && p.status != 'aktif')
        .toList();
    return [...active, ...closed];
  }

  static List<String> get projectOptions {
    if (!DummyDataConfig.useDummyData) return [];
    return sortedProjects.map((p) => p.projectName).toList();
  }

  // Structured Operational Areas (Relasi berdasarkan idProject)
  static final List<AreaModel> areas = [
    // 1. PJU Kota Semarang 2026 (Aktif)
    AreaModel(
      idArea: 101,
      idProject: 1,
      areaName: 'Tembalang',
      totalLamps: 48,
    ),
    AreaModel(
      idArea: 102,
      idProject: 1,
      areaName: 'Pedurungan',
      totalLamps: 35,
    ),
    AreaModel(
      idArea: 103,
      idProject: 1,
      areaName: 'Semarang Timur',
      totalLamps: 28,
    ),

    // 2. PJU Kecamatan Banyumanik (Aktif)
    AreaModel(
      idArea: 201,
      idProject: 2,
      areaName: 'Banyumanik Utara',
      totalLamps: 24,
    ),
    AreaModel(
      idArea: 202,
      idProject: 2,
      areaName: 'Banyumanik Selatan',
      totalLamps: 30,
    ),

    // 3. PJU Kecamatan Tembalang (Aktif)
    AreaModel(
      idArea: 301,
      idProject: 3,
      areaName: 'Tembalang Barat',
      totalLamps: 40,
    ),
    AreaModel(
      idArea: 302,
      idProject: 3,
      areaName: 'Tembalang Timur',
      totalLamps: 32,
    ),

    // 4. PJU Kota Semarang 2025 (Selesai)
    AreaModel(
      idArea: 401,
      idProject: 4,
      areaName: 'Semarang Barat',
      totalLamps: 60,
    ),

    // 5. PJU Semarang Barat 2025 (Selesai)
    AreaModel(
      idArea: 501,
      idProject: 5,
      areaName: 'Krobokan',
      totalLamps: 38,
    ),
  ];

  /// Ambil daftar AreaModel berdasarkan idProject
  static List<AreaModel> getAreasByProjectId(int projectId) {
    if (!DummyDataConfig.useDummyData) return [];
    return areas.where((a) => a.idProject == projectId).toList();
  }

  /// Ambil Project berdasarkan nama
  static Project? getProjectByName(String projectName) {
    try {
      return projects.firstWhere((p) => p.projectName == projectName);
    } catch (_) {
      return null;
    }
  }

  /// Ambil Project berdasarkan idProject
  static Project? getProjectById(int projectId) {
    try {
      return projects.firstWhere((p) => p.idProject == projectId);
    } catch (_) {
      return null;
    }
  }

  /// Map backward compatibility untuk operationalAreasMap
  static List<Map<String, dynamic>> get operationalAreasMap {
    if (!DummyDataConfig.useDummyData) return [];
    return areas.map((a) {
      final proj = getProjectById(a.idProject);
      final isClosed = proj?.status == 'closed' || proj?.status == 'selesai';
      return {
        'id': a.idArea,
        'projectId': a.idProject,
        'title': a.areaName,
        'location': proj?.location ?? 'Semarang, Jawa Tengah',
        'dateRange': isClosed
            ? '01 Jan 2025 - 31 Des 2025'
            : '10 Mei 2026 - 20 Des 2026',
        'totalLamps': a.totalLamps,
        'status': isClosed ? 'selesai' : 'aktif',
      };
    }).toList();
  }

  // Lamp Types
  static final List<LampTypeItem> lampTypes = [
    const LampTypeItem(
      id: 1,
      name: 'LED 90W',
      description: 'Lampu LED PJU 90 Watt hemat energi untuk jalan lokal.',
      icon: Icons.lightbulb_outline_rounded,
    ),
    const LampTypeItem(
      id: 2,
      name: 'LED 120W',
      description: 'Lampu LED PJU 120 Watt standar jalan arteri sekunder.',
      icon: Icons.lightbulb_rounded,
    ),
    const LampTypeItem(
      id: 3,
      name: 'LED 150W',
      description: 'Lampu LED PJU 150 Watt daya tinggi untuk jalan protokol.',
      icon: Icons.highlight_rounded,
    ),
    const LampTypeItem(
      id: 4,
      name: 'Smart Solar PJU',
      description: 'Lampu jalan tenaga surya otomatis dengan sensor cahaya.',
      icon: Icons.solar_power_outlined,
    ),
  ];

  static String _formatHistoryDate(DateTime date, String timeStr) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}, $timeStr';
  }

  // History Items (Terkait userId, projectId, dan tanggal yang bervariasi)
  static List<HistoryLampItem> get historyItems {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final d0 = today.add(const Duration(hours: 8, minutes: 15));
    final d2 = today
        .subtract(const Duration(days: 2))
        .add(const Duration(hours: 9, minutes: 30));
    final d3 = today
        .subtract(const Duration(days: 3))
        .add(const Duration(hours: 10, minutes: 15));
    final d4 = today
        .subtract(const Duration(days: 4))
        .add(const Duration(hours: 15, minutes: 20));
    final d5 = today
        .subtract(const Duration(days: 5))
        .add(const Duration(hours: 14, minutes: 10));
    final d10 = today
        .subtract(const Duration(days: 10))
        .add(const Duration(hours: 15, minutes: 30));
    final d15 = today
        .subtract(const Duration(days: 15))
        .add(const Duration(hours: 11, minutes: 20));
    final d25 = today
        .subtract(const Duration(days: 25))
        .add(const Duration(hours: 16, minutes: 45));
    final d45 = today
        .subtract(const Duration(days: 45))
        .add(const Duration(hours: 10, minutes: 0));

    return [
      // 1. User 1 (Teknisi A), Project 1 (PJU Kota Semarang 2026) - HARI INI
      HistoryLampItem(
        idHistory: 1,
        userId: 1,
        projectId: 1,
        areaId: 101,
        kode: 'JKT-2025-001',
        jenis: 'LED 90W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Prof. Soedarto, Tembalang',
        koordinat: '-7.051234, 110.439812',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d0, '08:15 WIB'),
        tanggal: d0,
      ),
      // 2. User 1 (Teknisi A), Project 1 (PJU Kota Semarang 2026) - 2 HARI LALU (7 Hari, 1 Bulan)
      HistoryLampItem(
        idHistory: 2,
        userId: 1,
        projectId: 1,
        areaId: 102,
        kode: 'JKT-2025-002',
        jenis: 'LED 120W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Majapahit No. 45, Pedurungan',
        koordinat: '-7.012390, 110.461290',
        fotoCount: '4 Foto Lampu',
        waktu: _formatHistoryDate(d2, '09:30 WIB'),
        tanggal: d2,
      ),
      // 3. User 1 (Teknisi A), Project 1 (PJU Kota Semarang 2026) - 5 HARI LALU (7 Hari, 1 Bulan)
      HistoryLampItem(
        idHistory: 3,
        userId: 1,
        projectId: 1,
        areaId: 103,
        kode: 'JKT-2025-003',
        jenis: 'LED 150W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Gajah Raya No. 18, Gayamsari',
        koordinat: '-7.001240, 110.442110',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d5, '14:10 WIB'),
        tanggal: d5,
      ),
      // 4. User 1 (Teknisi A), Project 1 (PJU Kota Semarang 2026) - 15 HARI LALU (1 Bulan)
      HistoryLampItem(
        idHistory: 4,
        userId: 1,
        projectId: 1,
        areaId: 101,
        kode: 'JKT-2025-004',
        jenis: 'Smart Solar PJU',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Ngesrep Timur V, Tembalang',
        koordinat: '-7.054320, 110.428900',
        fotoCount: '2 Foto Lampu',
        waktu: _formatHistoryDate(d15, '11:20 WIB'),
        tanggal: d15,
      ),
      // 5. User 1 (Teknisi A), Project 1 (PJU Kota Semarang 2026) - 25 HARI LALU (1 Bulan)
      HistoryLampItem(
        idHistory: 5,
        userId: 1,
        projectId: 1,
        areaId: 102,
        kode: 'JKT-2025-005',
        jenis: 'LED 90W',
        status: 'Pending Verification',
        isVerified: false,
        lokasi: 'Jl. Fatmawati No. 8, Pedurungan',
        koordinat: '-7.025110, 110.468200',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d25, '16:45 WIB'),
        tanggal: d25,
      ),
      // 6. User 1 (Teknisi A), Project 1 (PJU Kota Semarang 2026) - 45 HARI LALU (Di luar 1 bulan)
      HistoryLampItem(
        idHistory: 6,
        userId: 1,
        projectId: 1,
        areaId: 101,
        kode: 'JKT-2025-006',
        jenis: 'LED 120W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Sirojudin No. 2, Tembalang',
        koordinat: '-7.050120, 110.435600',
        fotoCount: '4 Foto Lampu',
        waktu: _formatHistoryDate(d45, '10:00 WIB'),
        tanggal: d45,
      ),
      // --- DUMMY DATA MEI 2025 (Untuk Testing Range Date Picker: 14 Mei - 17 Mei 2025) ---
      HistoryLampItem(
        idHistory: 101,
        userId: 1,
        projectId: 1,
        areaId: 101,
        kode: 'JKT-2025-M10',
        jenis: 'LED 90W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Banjarsari No. 12, Tembalang',
        koordinat: '-7.056120, 110.431200',
        fotoCount: '3 Foto Lampu',
        waktu: '10 Mei 2025, 08:00 WIB',
        tanggal: DateTime(2025, 5, 10, 8, 0),
      ),
      HistoryLampItem(
        idHistory: 102,
        userId: 1,
        projectId: 1,
        areaId: 101,
        kode: 'JKT-2025-M12',
        jenis: 'LED 120W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Bulusan Selatan No. 5, Tembalang',
        koordinat: '-7.058300, 110.439100',
        fotoCount: '4 Foto Lampu',
        waktu: '12 Mei 2025, 09:30 WIB',
        tanggal: DateTime(2025, 5, 12, 9, 30),
      ),
      HistoryLampItem(
        idHistory: 103,
        userId: 1,
        projectId: 1,
        areaId: 102,
        kode: 'JKT-2025-M14',
        jenis: 'LED 90W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Majapahit No. 110, Pedurungan',
        koordinat: '-7.014200, 110.463500',
        fotoCount: '3 Foto Lampu',
        waktu: '14 Mei 2025, 08:30 WIB',
        tanggal: DateTime(2025, 5, 14, 8, 30),
      ),
      HistoryLampItem(
        idHistory: 104,
        userId: 1,
        projectId: 1,
        areaId: 102,
        kode: 'JKT-2025-M15',
        jenis: 'LED 150W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Brigjen Sudiarto No. 45, Pedurungan',
        koordinat: '-7.016500, 110.467800',
        fotoCount: '4 Foto Lampu',
        waktu: '15 Mei 2025, 10:15 WIB',
        tanggal: DateTime(2025, 5, 15, 10, 15),
      ),
      HistoryLampItem(
        idHistory: 105,
        userId: 1,
        projectId: 1,
        areaId: 103,
        kode: 'JKT-2025-M16',
        jenis: 'Smart Solar PJU',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Dr. Cipto No. 22, Semarang Timur',
        koordinat: '-6.993400, 110.431200',
        fotoCount: '3 Foto Lampu',
        waktu: '16 Mei 2025, 13:45 WIB',
        tanggal: DateTime(2025, 5, 16, 13, 45),
      ),
      HistoryLampItem(
        idHistory: 106,
        userId: 1,
        projectId: 1,
        areaId: 103,
        kode: 'JKT-2025-M17',
        jenis: 'LED 120W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Raden Patah No. 80, Semarang Timur',
        koordinat: '-6.981200, 110.428900',
        fotoCount: '3 Foto Lampu',
        waktu: '17 Mei 2025, 16:20 WIB',
        tanggal: DateTime(2025, 5, 17, 16, 20),
      ),
      HistoryLampItem(
        idHistory: 107,
        userId: 1,
        projectId: 1,
        areaId: 101,
        kode: 'JKT-2025-M20',
        jenis: 'LED 90W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Gondang Barat, Tembalang',
        koordinat: '-7.059100, 110.441000',
        fotoCount: '2 Foto Lampu',
        waktu: '20 Mei 2025, 11:00 WIB',
        tanggal: DateTime(2025, 5, 20, 11, 0),
      ),
      HistoryLampItem(
        idHistory: 108,
        userId: 1,
        projectId: 1,
        areaId: 102,
        kode: 'JKT-2025-M25',
        jenis: 'LED 150W',
        status: 'Pending Verification',
        isVerified: false,
        lokasi: 'Jl. Wolter Monginsidi, Pedurungan',
        koordinat: '-7.008900, 110.472100',
        fotoCount: '3 Foto Lampu',
        waktu: '25 Mei 2025, 14:00 WIB',
        tanggal: DateTime(2025, 5, 25, 14, 0),
      ),
      HistoryLampItem(
        idHistory: 109,
        userId: 1,
        projectId: 1,
        areaId: 103,
        kode: 'JKT-2025-M30',
        jenis: 'LED 120W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Barito No. 15, Semarang Timur',
        koordinat: '-6.995600, 110.438900',
        fotoCount: '4 Foto Lampu',
        waktu: '30 Mei 2025, 09:10 WIB',
        tanggal: DateTime(2025, 5, 30, 9, 10),
      ),
      // 7. User 1 (Teknisi A), Project 2 (PJU Kecamatan Banyumanik) - HARI INI
      HistoryLampItem(
        idHistory: 7,
        userId: 1,
        projectId: 2,
        areaId: 201,
        kode: 'BMS-2025-001',
        jenis: 'LED 90W',
        status: 'Pending Verification',
        isVerified: false,
        lokasi: 'Jl. Setiabudi No. 12, Banyumanik Utara',
        koordinat: '-7.068112, 110.419230',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d0, '13:20 WIB'),
        tanggal: d0,
      ),
      // 8. User 1 (Teknisi A), Project 2 (PJU Kecamatan Banyumanik) - 3 HARI LALU
      HistoryLampItem(
        idHistory: 8,
        userId: 1,
        projectId: 2,
        areaId: 202,
        kode: 'BMS-2025-003',
        jenis: 'LED 120W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Sukun Raya No. 5, Banyumanik Selatan',
        koordinat: '-7.069500, 110.415200',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d3, '10:15 WIB'),
        tanggal: d3,
      ),
      // 9. User 2 (Teknisi B), Project 1 (PJU Kota Semarang 2026) - HARI INI
      HistoryLampItem(
        idHistory: 9,
        userId: 2,
        projectId: 1,
        areaId: 103,
        kode: 'JKT-2025-007',
        jenis: 'LED 150W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Pemuda No. 88, Semarang Timur',
        koordinat: '-6.984210, 110.415320',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d0, '10:45 WIB'),
        tanggal: d0,
      ),
      // 10. User 2 (Teknisi B), Project 1 (PJU Kota Semarang 2026) - 4 HARI LALU
      HistoryLampItem(
        idHistory: 10,
        userId: 2,
        projectId: 1,
        areaId: 103,
        kode: 'JKT-2025-008',
        jenis: 'LED 90W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. MT Haryono No. 120, Semarang Timur',
        koordinat: '-6.989100, 110.422300',
        fotoCount: '2 Foto Lampu',
        waktu: _formatHistoryDate(d4, '15:20 WIB'),
        tanggal: d4,
      ),
      // 11. User 2 (Teknisi B), Project 2 (PJU Kecamatan Banyumanik) - HARI INI
      HistoryLampItem(
        idHistory: 11,
        userId: 2,
        projectId: 2,
        areaId: 202,
        kode: 'BMS-2025-002',
        jenis: 'LED 120W',
        status: 'Rejected',
        isVerified: false,
        lokasi: 'Jl. Perintis Kemerdekaan, Banyumanik Selatan',
        koordinat: '-7.071240, 110.410210',
        fotoCount: '2 Foto Lampu',
        waktu: _formatHistoryDate(d0, '14:15 WIB'),
        tanggal: d0,
      ),
      // 12. User 1 (Teknisi A), Project 4 (PJU Kota Semarang 2025 - Selesai) - HARI INI
      HistoryLampItem(
        idHistory: 12,
        userId: 1,
        projectId: 4,
        areaId: 401,
        kode: 'SMG-2025-088',
        jenis: 'LED 150W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Pamularsih No. 10, Semarang Barat',
        koordinat: '-6.991200, 110.395100',
        fotoCount: '4 Foto Lampu',
        waktu: _formatHistoryDate(d0, '11:00 WIB'),
        tanggal: d0,
      ),
      // 13. User 1 (Teknisi A), Project 4 (PJU Kota Semarang 2025 - Selesai) - 10 HARI LALU
      HistoryLampItem(
        idHistory: 13,
        userId: 1,
        projectId: 4,
        areaId: 401,
        kode: 'SMG-2025-089',
        jenis: 'LED 90W',
        status: 'Tersimpan',
        isVerified: true,
        lokasi: 'Jl. Pusponjolo Barat, Semarang Barat',
        koordinat: '-6.992500, 110.398000',
        fotoCount: '3 Foto Lampu',
        waktu: _formatHistoryDate(d10, '15:30 WIB'),
        tanggal: d10,
      ),
    ];
  }

  /// Filter riwayat berdasarkan user yang login (currentUser.id) DAN project yang dipilih (projectId)
  static List<HistoryLampItem> getHistoryByUserAndProject({
    required int userId,
    required int? projectId,
  }) {
    if (!DummyDataConfig.useDummyData) return [];
    if (projectId == null) return [];
    return historyItems.where((item) {
      return item.userId == userId && item.projectId == projectId;
    }).toList();
  }

  // Notifications
  static final List<NotificationItem> notifications = [
    NotificationItem(
      id: 1,
      title: 'Persetujuan Data Pendataan',
      time: '08:30 WIB',
      content:
          'Data pendataan lampu LMP-001 di Tembalang telah disetujui oleh Supervisor.',
      icon: Icons.check_circle_outline_rounded,
      iconColor: const Color(0xFF16A34A),
      iconBackgroundColor: const Color(0xFFF0FDF4),
      isUnread: true,
      section: 'TERBARU',
      boldText: 'LMP-001',
    ),
    NotificationItem(
      id: 2,
      title: 'Catatan Penolakan Data',
      time: '11:00 WIB',
      content:
          'Data pendataan LMP-003 membutuhkan foto ulang karena dokumentasi kurang jelas.',
      icon: Icons.error_outline_rounded,
      iconColor: const Color(0xFFDC2626),
      iconBackgroundColor: const Color(0xFFFEF2F2),
      isUnread: true,
      section: 'TERBARU',
      boldText: 'LMP-003',
    ),
    NotificationItem(
      id: 3,
      title: 'Informasi Project Baru',
      time: 'Kemarin, 16:20',
      content: 'Anda telah ditambahkan ke Proyek PJU Kota Semarang 2026.',
      icon: Icons.info_outline_rounded,
      iconColor: const Color(0xFF0C5DA5),
      iconBackgroundColor: const Color(0xFFEFF6FF),
      isUnread: false,
      section: 'SEBELUMNYA',
      boldText: 'PJU Kota Semarang 2026',
    ),
    NotificationItem(
      id: 4,
      title: 'Pembaruan Sistem Pendataan',
      time: '3 Hari Lalu',
      content:
          'Aplikasi versi 1.2 telah diperbarui dengan fitur deteksi koordinat cepat.',
      icon: Icons.system_update_alt_rounded,
      iconColor: const Color(0xFF6B7280),
      iconBackgroundColor: const Color(0xFFF3F4F6),
      isUnread: false,
      section: 'SEBELUMNYA',
    ),
  ];

  // Profile Data
  static const Map<String, String> profileData = {
    'name': 'Rizky Teknisi Field',
    'email': 'rizky.teknisi@bandell.com',
    'phone': '+62 812-9876-5432',
    'role': 'Senior Field Engineer (Semarang)',
  };
}
