import 'package:flutter/material.dart';

class AppColors {
  // --- WARNA UTAMA (Brand, Header, Splash, & Tombol) ---
  static const Color primary = Color(
    0xFF0C5DA5,
  ); // Header TopBar, Splash, Tombol Simpan
  static const Color primaryDark = Color(0xFF084B83); // Biru Gelap
  static const Color primaryLight = Color(
    0x1A0C5DA5,
  ); // Icon GPS & Foto (Transparan)
  static const Color background = Colors.white; // Background Umum
  static const Color backgroundWhite = Color(
    0xFFFFFFFF,
  ); // Background Putih Layar
  static const Color headerTitle = Color(0xFFFFFFFF); // Teks Judul Header
  static const Color headerSubtitle = Color(
    0xE6FFFFFF,
  ); // Teks Sub-judul Header
  static const Color logoColor = Color(0xFFFFFFFF); // Warna Logo

  // --- WARNA TEKS & TIPOGRAFI (Slate Palette) ---
  static const Color textHeading = Color(0xFF1E293B); // Slate 800 - Judul Utama
  static const Color textPrimary = Color(
    0xFF1F2937,
  ); // Teks Judul & Label Gelap
  static const Color textDark = Color(
    0xFF334155,
  ); // Slate 700 - Teks Konten Gelap
  static const Color textBody = Color(
    0xFF475569,
  ); // Slate 600 - Teks Body/Deskripsi
  static const Color textSecondary = Color(
    0xFF4B5563,
  ); // Teks Keterangan Abu-abu
  static const Color textMuted = Color(
    0xFF64748B,
  ); // Slate 500 - Subtitle & Keterangan
  static const Color textSubtle = Color(
    0xFF94A3B8,
  ); // Slate 400 - Placeholder & Icon Redup
  static const Color labelColor = Color(0xFF4B5563); // Label Input Form
  static const Color hintColor = Color(0xFF9CA3AF); // Placeholder Kotak Ketik
  static const Color linkText = Color(0xFF0C5DA5); // Teks Link / Bantuan
  static const Color buttonText = Color(0xFFFFFFFF); // Teks Tombol Putih

  // --- FORM, BORDER, & KOTAK INPUT ---
  static const Color iconColor = Color(0xFF9CA3AF); // Icon Abu-abu Standar
  static const Color border = Color(0xFFE5E7EB); // Garis Kotak Input (Biasa)
  static const Color borderLight = Color(
    0xFFE2E8F0,
  ); // Slate 200 - Garis Kartu / Pembatas Halus
  static const Color borderMedium = Color(
    0xFFCBD5E1,
  ); // Slate 300 - Border Input & Button Outline
  static const Color borderFocused = Color(
    0xFF0C5DA5,
  ); // Garis Kotak Input (Saat Diketik)
  static const Color divider = Color(
    0xFFF1F5F9,
  ); // Slate 100 - Divider Garis Pemisah
  static const Color inputBackground = Color(
    0xFFF8FAFC,
  ); // Background Kotak Ketik
  static const Color buttonBackground = Color(
    0xFF0C5DA5,
  ); // Background Tombol Utama
  static const Color cardBackground = Color(
    0xFFFFFFFF,
  ); // Background Kartu Putih

  // --- HALAMAN PROFILE & BADGE ---
  static const Color profileGradientStart = Color(
    0xFF0072CE,
  ); // Gradasi Atas Profile
  static const Color profileGradientEnd = Color(
    0xFF265C8C,
  ); // Gradasi Bawah Profile
  static const Color roleBadgeBackground = Color(
    0xFFEBF3FC,
  ); // Background Pill Badge Role
  static const Color roleBadgeBorder = Color(
    0xFFBFDBFE,
  ); // Border Pill Badge Role
  static const Color roleBadgeText = Color(
    0xFF0C5DA5,
  ); // Teks & Icon Pill Badge Role
  static const Color avatarCircleBackground = Color(
    0xFFE2EBF8,
  ); // Background Lingkaran Avatar
  static const Color verifiedBlue = Color(0xFF0072CE); // Centang Biru Verified

  // --- STATUS & FEEDBACK (Semantic Colors) ---
  static const Color error = Color(
    0xFFEF4444,
  ); // Banner / Pesan Error / Asterisk Wajib
  static const Color errorLight = Color(0x1AEF4444); // Background Pesan Error
  static const Color deleteRed = Color(0xFFC51D1D); // Tombol Hapus Lampu
  static const Color logoutRed = Color(0xFFEF4444); // Tombol Keluar / Logout
  static const Color logoutRedBg = Color(
    0xFFFEE2E2,
  ); // Background Icon Logout di Dialog
  static const Color popupPanelBackground = Color(0xFFF4F6FA); // Dialog Popup
  static const Color popupRedLight = Color(0xFFFDE8E8); // Icon Hapus di Popup
  static const Color success = Color(0xFF10B981); // Popup Centang Sukses
  static const Color successLight = Color(0x1A10B981); // Background Sukses
  static const Color warning = Color(0xFFF59E0B); // Status Menunggu Verifikasi
  static const Color warningLight = Color(
    0x1AF59E0B,
  ); // Background Status Kuning
  static const Color warningBorder = Color(0xFFFDE68A); // Border Kotak Kuning

  // --- STATUS BADGE (Riwayat / Notifikasi / Kartu Lampu) ---
  // Status: Ditolak
  static const Color statusDitolakText = Color(0xFFDC2626);
  static const Color statusDitolakBg = Color(0xFFFEE2E2);
  static const Color statusDitolakBorder = Color(0xFFFECACA);
  static const Color statusDitolakCircleBg = Color(0xFFFDE2E2);

  // Status: Terverifikasi / Selesai
  static const Color statusTerverifikasiText = Color(0xFF15803D);
  static const Color statusTerverifikasiBg = Color(0xFFDCFCE7);
  static const Color statusTerverifikasiBorder = Color(0xFFBBF7D0);

  // Status: Tersimpan
  static const Color statusTersimpanText = Color(0xFF0369A1);
  static const Color statusTersimpanBg = Color(0xFFE0F2FE);
  static const Color statusTersimpanBorder = Color(0xFFBAE6FD);

  // Status: Menunggu Verifikasi
  static const Color statusMenungguText = Color(0xFFB45309);
  static const Color statusMenungguBg = Color(0xFFFEF3C7);
  static const Color statusMenungguBorder = Color(0xFFFDE68A);

  // --- HALAMAN RIWAYAT & KARTU PROYEK ---
  static const Color searchBackground = Color(
    0xFFF3F4F6,
  ); // Kotak Search di Riwayat
  static const Color cardPrimary = Color(0xFF0C5DA5); // Kartu Proyek Biru
  static const Color cardTextWhite = Color(0xFFFFFFFF); // Teks di Kartu Proyek
  static const Color cardTextSubtle = Color(
    0xE6FFFFFF,
  ); // Sub-teks di Kartu Proyek
  static const Color cardButtonWhite = Color(
    0xFFFFFFFF,
  ); // Tombol di Kartu Proyek
  static const Color shadowColor = Color(0x1A0C5DA5); // Bayangan Kartu
  static const Color accentBlue = Color(0xFF2563EB); // Biru Aksen

  // --- METODE INPUT (REALTIME VS MANUAL) ---
  static const Color realtimeGreen = Color(
    0xFF16A34A,
  ); // Kartu Opsi Real-time (Hijau)
  static const Color realtimeBackground = Color(
    0xFFF0FDF4,
  ); // Background Kartu Real-time
  static const Color realtimeBorder = Color(
    0xFFBBF7D0,
  ); // Border Kartu Real-time
  static const Color manualOrange = Color(
    0xFFEA580C,
  ); // Kartu Opsi Manual (Oranye)
  static const Color manualBackground = Color(
    0xFFFFF7ED,
  ); // Background Kartu Manual
  static const Color manualBorder = Color(0xFFFFEDD5); // Border Kartu Manual
  static const Color infoBlue = Color(0xFF0C5DA5); // Kotak Info Petunjuk (Biru)
  static const Color infoBackground = Color(
    0xFFEFF6FF,
  ); // Background Kotak Info
  static const Color infoBorder = Color(0xFFBFDBFE); // Border Kotak Info

  // --- HALAMAN SCAN BARCODE (KAMERA) ---
  static const Color scanBackgroundDark = Color(
    0xFF0D121D,
  ); // Layar Hitam Kamera
  static const Color scanCardDark = Color(0xFF161F33); // Tombol Flash & Galeri
  static const Color scanCyan = Color(0xFF38BDF8); // Kotak Bidik Barcode (Cyan)
  static const Color scanCyanLight = Color(0x3338BDF8); // Efek Cahaya Bidik
  static const Color scanIconDark = Color(0xFF334155); // Border Scanner

  // --- HALAMAN LOGIN ---
  static const Color loginBlueGradientStart = Color(
    0xFF0C5DA5,
  ); // Gradasi Biru Form Login
  static const Color loginBlueGradientEnd = Color(
    0xFF094A85,
  ); // Gradasi Biru Gelap Login
  static const Color loginLinkCyan = Color(
    0xFF38BDF8,
  ); // Link Bantuan CS di Login
  static const Color loginErrorRed = Color(0xFFFF6B6B); // Teks Error Login

  // --- HALAMAN SPLASH ---
  static const Color splashButtonBg = Color(0xFF2878D7); // Tombol Masuk Splash

  // --- BOTTOM NAVBAR ---
  static const Color navActiveBackground = Color(
    0xFFEFF6FF,
  ); // Background Item Tab Aktif
  static const Color navInactive = Color(
    0xFF6B7280,
  ); // Icon / Teks Tab Nonaktif

  // --- AREA OPERASIONAL & KARTU UTAMA ---
  static const Color areaCardGradientStart = Color(
    0xFF0D4B85,
  ); // Gradasi Kartu Area Operasional Atas
  static const Color areaCardGradientEnd = Color(
    0xFF093766,
  ); // Gradasi Kartu Area Operasional Bawah

  // --- NOTIFIKASI & DIALOG ---
  static const Color notifUnreadAvatarBg = Color(
    0xFFE2EFFC,
  ); // Background Avatar Notif Belum Dibaca
  static const Color notifCardBorder = Color(
    0xFFE8EEF5,
  ); // Border Kartu Notifikasi
  static const Color notifSubCardBg = Color(
    0xFFE8F2FA,
  ); // Sub-container Notifikasi
  static const Color dialogPrimaryDark = Color(
    0xFF00447C,
  ); // Header Dialog Gelap

  // --- RIWAYAT & KOMPONEN BARCODE ---
  static const Color historyCardBackground = Color(
    0xFFFAFCFE,
  ); // Background Kartu Lampu Riwayat
  static const Color surfaceSubtle = Color(
    0xFFF0F4FA,
  ); // Container Subtitle / Icon Latar
  static const Color barcodeBorderInactive = Color(
    0xFFC7DBEC,
  ); // Border Barcode Non-aktif
  static const Color barcodeTint = Color(0xFFA3C7E8); // Tint Barcode
  static const Color barcodeTextDark = Color(0xFF1E2B45); // Teks Barcode Gelap
  static const Color statusRevisiText = Color(
    0xFFD97706,
  ); // Teks Status Revisi / Warning Amber

  // --- DATE PICKER & WIDGET INPUT ---
  static const Color datePickerAccent = Color(
    0xFFB8D5ED,
  ); // Aksen Header Kalender
  static const Color datePickerDisabledBg = Color(
    0x5900569E,
  ); // Tombol Disabled Kalender BG
  static const Color datePickerDisabledFg = Color(
    0x99FFFFFF,
  ); // Tombol Disabled Kalender FG

  // --- CUSTOM FEEDBACK & TOAST ---
  static const Color feedbackSuccessText = Color(
    0xFF166534,
  ); // Teks Feedback Sukses Gelap
  static const Color feedbackErrorText = Color(
    0xFF991B1B,
  ); // Teks Feedback Gagal Gelap
  static const Color feedbackErrorBg = Color(
    0xFFFEF2F2,
  ); // Background Feedback Gagal
  static const Color feedbackErrorBorder = Color(
    0xFFFECACA,
  ); // Border Feedback Gagal

  // --- SHADOW & OVERLAY SEMANTIK ---
  static const Color shadowLight = Color(0x14000000); // Shadow Halus (8% hitam)
  static const Color shadowMedium = Color(
    0x1A000000,
  ); // Shadow Sedang (10% hitam)
  static const Color shadowSubtle = Color(
    0x0A000000,
  ); // Shadow Tipis (4% hitam)
  static const Color shadowFaint = Color(
    0x08000000,
  ); // Shadow Sangat Halus (3% hitam)
  static const Color shadowMinimal = Color(
    0x06000000,
  ); // Shadow Minimal (2% hitam)
  static const Color shadowSoft = Color(0x0F000000); // Shadow Lembut (6% hitam)
  static const Color shadowDark = Color(0x20000000); // Shadow Gelap (12% hitam)
  static const Color shadowStrong = Color(
    0x29000000,
  ); // Shadow Kuat (16% hitam)
  static const Color whiteOverlay = Color(0x66FFFFFF); // White Alpha 40%
  static const Color whiteAlpha60 = Color(0x99FFFFFF); // White Alpha 60%
  static const Color whiteAlpha85 = Color(0xD9FFFFFF); // White Alpha 85%
  static const Color whiteAlpha90 = Color(0xE6FFFFFF); // White Alpha 90%

  // --- SKELETON / SHIMMER LOADING ---
  static const Color skeletonBase = Color(
    0xFFE2E8F0,
  ); // Slate 200 - Abu-abu dasar skeleton
  static const Color skeletonHighlight = Color(
    0xFFF8FAFC,
  ); // Slate 50 - Kilau shimmer
  static const Color skeletonContainer = Color(
    0xFFE2E8F0,
  ); // Container skeleton abu-abu

  // --- WARNA DASAR & OVERLAY UNIVERSAL ---
  static const Color pureWhite = Color(0xFFFFFFFF);
  static const Color pureBlack = Color(0xFF000000);
  static const Color transparent = Color(0x00000000);
  static const Color whiteAlpha54 = Color(0x8AFFFFFF); // Putih 54%
  static const Color whiteAlpha70 = Color(0xB3FFFFFF); // Putih 70%
  static const Color blackAlpha12 = Color(0x1F000000); // Hitam 12%
  static const Color blackAlpha54 = Color(0x8A000000); // Hitam 54%
  static const Color barrierOverlay = Color(
    0x80000000,
  ); // Overlay Modal / Dialog 50%
  static const Color loginButtonBg = Color(0xFFFFFFFF); // Tombol Login Putih
  static const Color loginButtonDisabledBg = Color(
    0x99FFFFFF,
  ); // Tombol Login Disabled
  static const Color photoPreviewBackground = Color(
    0xFF000000,
  ); // Latar Preview Foto
}
