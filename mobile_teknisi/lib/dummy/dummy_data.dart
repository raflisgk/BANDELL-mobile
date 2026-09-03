import 'package:flutter/material.dart';
import '../models/project_model.dart';
import '../screens/history/history_lamp_card.dart';
import '../screens/lamp/lamp_page.dart';
import '../screens/notification/notification_page.dart';

class DummyDataConfig {
  /// Toggle this flag to true to show dummy testing data, or false to revert to empty/API state.
  static const bool useDummyData = true;
}

class DummyData {
  // Projects
  static final List<Project> projects = [
    Project(
      idProject: 101,
      projectName: 'PJU Kota Semarang 2026',
      location: 'Kota Semarang, Jawa Tengah',
      startDate: DateTime(2026, 1, 15),
      endDate: DateTime(2026, 12, 31),
      status: 'active',
    ),
    Project(
      idProject: 102,
      projectName: 'PJU Kecamatan Tembalang',
      location: 'Tembalang, Semarang',
      startDate: DateTime(2026, 3, 1),
      endDate: DateTime(2026, 9, 30),
      status: 'active',
    ),
    Project(
      idProject: 103,
      projectName: 'PJU Kota Semarang 2025 (Selesai)',
      location: 'Kota Semarang',
      startDate: DateTime(2025, 1, 1),
      endDate: DateTime(2025, 12, 31),
      status: 'closed',
    ),
  ];

  static List<String> get projectOptions {
    if (!DummyDataConfig.useDummyData) return [];
    return projects.map((p) => p.projectName).toList();
  }

  // Operational Areas
  static final List<Map<String, dynamic>> operationalAreasMap = [
    {
      'id': 1,
      'title': 'Tembalang (Banyak Lampu)',
      'location': 'Semarang Selatan, Jawa Tengah',
      'dateRange': '10 Mei 2026 - 20 Des 2026',
      'totalLamps': 48,
      'status': 'aktif',
    },
    {
      'id': 2,
      'title': 'Banyumanik (Sedikit Lampu)',
      'location': 'Semarang Atas, Jawa Tengah',
      'dateRange': '01 Feb 2026 - 30 Jun 2026',
      'totalLamps': 6,
      'status': 'aktif',
    },
    {
      'id': 3,
      'title': 'Pedurungan (Selesai)',
      'location': 'Semarang Timur, Jawa Tengah',
      'dateRange': '01 Jan 2025 - 31 Des 2025',
      'totalLamps': 120,
      'status': 'selesai',
    },
  ];

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

  // History Items (Teknisi pendataan hari ini & lalu)
  static final List<HistoryLampItem> historyItems = [
    const HistoryLampItem(
      kode: 'LMP-001',
      jenis: 'LED 90W',
      status: 'Tersimpan',
      isVerified: true,
      lokasi: 'Jl. Prof. Soedarto, Tembalang',
      koordinat: '-7.051234, 110.439812',
      fotoCount: '3 Foto Lampu',
      waktu: '08:15 WIB',
    ),
    const HistoryLampItem(
      kode: 'LMP-002',
      jenis: 'LED 120W',
      status: 'Pending Verification',
      isVerified: false,
      lokasi: 'Jl. Ngesrep Timur V, Banyumanik',
      koordinat: '-7.042110, 110.428910',
      fotoCount: '4 Foto Lampu',
      waktu: '09:30 WIB',
    ),
    const HistoryLampItem(
      kode: 'LMP-003',
      jenis: 'LED 150W',
      status: 'Rejected',
      isVerified: false,
      lokasi: 'Jl. Majapahit No. 120, Pedurungan',
      koordinat: '-7.012390, 110.461290',
      fotoCount: '2 Foto Lampu',
      waktu: '10:45 WIB',
    ),
    const HistoryLampItem(
      kode: 'LMP-004',
      jenis: 'LED 90W',
      status: 'Tersimpan',
      isVerified: true,
      lokasi: 'Jl. Setiabudi No. 88, Srondol',
      koordinat: '-7.068112, 110.419230',
      fotoCount: '5 Foto Lampu',
      waktu: '13:20 WIB',
    ),
    const HistoryLampItem(
      kode: 'LMP-005',
      jenis: 'LED 150W',
      status: 'Tersimpan',
      isVerified: true,
      lokasi: 'Jl. Pandanaran No. 45, Semarang',
      koordinat: '-6.984210, 110.415320',
      fotoCount: '3 Foto Lampu',
      waktu: '14:50 WIB',
    ),
  ];

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
