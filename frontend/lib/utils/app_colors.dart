import 'package:flutter/material.dart';

class AppColors {
  // --- WARNA UTAMA (Header, Splash, & Tombol) ---
  static const Color primary = Color(0xFF0C5DA5);         // Header TopBar, Splash, Tombol Simpan
  static const Color primaryLight = Color(0x1A0C5DA5);    // Icon GPS & Foto (Transparan)
  static const Color background = Colors.white;           // Background Umum
  static const Color backgroundWhite = Color(0xFFFFFFFF); // Background Putih Layar
  static const Color headerTitle = Color(0xFFFFFFFF);     // Teks Judul Header
  static const Color headerSubtitle = Color(0xE6FFFFFF);  // Teks Sub-judul Header
  static const Color logoColor = Color(0xFFFFFFFF);       // Warna Logo

  // --- WARNA TEKS ---
  static const Color textPrimary = Color(0xFF1F2937);     // Teks Judul & Label Gelap
  static const Color textSecondary = Color(0xFF4B5563);   // Teks Keterangan Abu-abu
  static const Color labelColor = Color(0xFF4B5563);       // Label Input Form
  static const Color hintColor = Color(0xFF9CA3AF);        // Placeholder Kotak Ketik
  static const Color linkText = Color(0xFF0C5DA5);         // Teks Link / Bantuan
  static const Color buttonText = Color(0xFFFFFFFF);       // Teks Tombol Putih

  // --- FORM & KOTAK INPUT ---
  static const Color iconColor = Color(0xFF9CA3AF);        // Icon Abu-abu Standar
  static const Color border = Color(0xFFE5E7EB);           // Garis Kotak Input (Biasa)
  static const Color borderFocused = Color(0xFF0C5DA5);    // Garis Kotak Input (Saat Diketik)
  static const Color inputBackground = Color(0xFFF8FAFC);  // Background Kotak Ketik
  static const Color buttonBackground = Color(0xFF0C5DA5); // Background Tombol Utama
  static const Color cardBackground = Color(0xFFFFFFFF);   // Background Kartu Putih

  // --- STATUS & POPUP ---
  static const Color error = Color(0xFFEF4444);            // Banner / Pesan Error
  static const Color errorLight = Color(0x1AEF4444);       // Background Pesan Error
  static const Color deleteRed = Color(0xFFC51D1D);        // Tombol Hapus Lampu
  static const Color popupPanelBackground = Color(0xFFF4F6FA); // Dialog Popup
  static const Color popupRedLight = Color(0xFFFDE8E8);    // Icon Hapus di Popup
  static const Color success = Color(0xFF10B981);          // Popup Centang Sukses
  static const Color successLight = Color(0x1A10B981);     // Background Sukses
  static const Color warning = Color(0xFFF59E0B);          // Status Menunggu Verifikasi
  static const Color warningLight = Color(0x1AF59E0B);     // Background Status Kuning
  static const Color warningBorder = Color(0xFFFDE68A);    // Border Kotak Kuning

  // --- HALAMAN RIWAYAT & KARTU PROYEK ---
  static const Color searchBackground = Color(0xFFF3F4F6); // Kotak Search di Riwayat
  static const Color cardPrimary = Color(0xFF0C5DA5);      // Kartu Proyek Biru
  static const Color cardTextWhite = Color(0xFFFFFFFF);    // Teks di Kartu Proyek
  static const Color cardTextSubtle = Color(0xE6FFFFFF);   // Sub-teks di Kartu Proyek
  static const Color cardButtonWhite = Color(0xFFFFFFFF);  // Tombol di Kartu Proyek
  static const Color shadowColor = Color(0x1A0C5DA5);      // Bayangan Kartu

  // --- METODE INPUT (REALTIME VS MANUAL) ---
  static const Color realtimeGreen = Color(0xFF16A34A);      // Kartu Opsi Real-time (Hijau)
  static const Color realtimeBackground = Color(0xFFF0FDF4); // Background Kartu Real-time
  static const Color realtimeBorder = Color(0xFFBBF7D0);     // Border Kartu Real-time
  static const Color manualOrange = Color(0xFFEA580C);       // Kartu Opsi Manual (Oranye)
  static const Color manualBackground = Color(0xFFFFF7ED);   // Background Kartu Manual
  static const Color manualBorder = Color(0xFFFFEDD5);       // Border Kartu Manual
  static const Color infoBlue = Color(0xFF0C5DA5);           // Kotak Info Petunjuk (Biru)
  static const Color infoBackground = Color(0xFFEFF6FF);     // Background Kotak Info
  static const Color infoBorder = Color(0xFFBFDBFE);         // Border Kotak Info

  // --- HALAMAN SCAN BARCODE (KAMERA) ---
  static const Color scanBackgroundDark = Color(0xFF0D121D); // Layar Hitam Kamera
  static const Color scanCardDark = Color(0xFF161F33);       // Tombol Flash & Galeri
  static const Color scanCyan = Color(0xFF38BDF8);           // Kotak Bidik Barcode (Cyan)
  static const Color scanCyanLight = Color(0x3338BDF8);      // Efek Cahaya Bidik
  static const Color scanIconDark = Color(0xFF334155);       // Border Scanner

  // --- HALAMAN LOGIN ---
  static const Color loginBlueGradientStart = Color(0xFF0C5DA5); // Gradasi Biru Form Login
  static const Color loginBlueGradientEnd = Color(0xFF094A85);   // Gradasi Biru Gelap Login
  static const Color loginLinkCyan = Color(0xFF38BDF8);          // Link Bantuan CS di Login
}
