# BANDELL Mobile Teknisi (Frontend)

Aplikasi mobile berbasis Flutter (Android) untuk operasional Teknisi Lapangan dalam pendataan dan verifikasi pemasangan panel/lampu PJU.

## Alur Aplikasi
`Login` → `Pilih Project` → `Area Operasional` → `Daftar Lampu` → `Tambah Data (Realtime / Manual)` → `Detail Lampu` → `Riwayat / Edit / Hapus`

## Cara Menjalankan
1. Pastikan Flutter SDK sudah terpasang di sistem.
2. Masuk ke direktori `frontend`:
   ```bash
   cd frontend
   ```
3. Install dependensi:
   ```bash
   flutter pub get
   ```
4. Jalankan aplikasi pada perangkat Android / emulator:
   ```bash
   flutter run
   ```
5. Build APK Release:
   ```bash
   flutter build apk --release
   ```

## Struktur Direktori
```text
frontend/
├── android/          # Native Android configuration & Gradle
├── assets/           # Gambar, logo, & icons
├── lib/              # Source code aplikasi Flutter
│   ├── models/       # Data models (User, Project, Lamp, Installation)
│   ├── screens/      # UI Screens (Login, Project, Lamp, Realtime, Manual, History, dll.)
│   ├── services/     # API Service, Auth Service, Hardware GPS/Barcode Service
│   ├── utils/        # App colors, page transitions, helpers
│   └── widgets/      # Reusable widgets (CustomFeedback, TopBar, BottomNavBar, dll.)
├── test/             # Widget & Unit tests
├── windows/          # Desktop Windows runner
├── pubspec.yaml      # Dependensi & konfigurasi asset Flutter
└── analysis_options.yaml # Aturan linter Dart
```

