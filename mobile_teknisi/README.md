# Mobile Teknisi

Aplikasi mobile untuk Teknisi berbasis Flutter (Android).

## Alur Aplikasi
`Login` → `Project` → `Area Operasional` → `Daftar Lampu` → `Tambah Data` → `Realtime/Manual` → `Detail Lampu` → `Edit/Hapus`

## Struktur Folder & File

```text
mobile_teknisi/
│
├── android/
│
├── assets/
│   ├── images/
│   └── icons/
│
├── lib/
│   ├── main.dart
│   │
│   ├── screens/
│   │   ├── login_page.dart
│   │   ├── project_page.dart
│   │   ├── area_page.dart
│   │   ├── lamp_page.dart
│   │   ├── metode_pendataan_page.dart
│   │   ├── scan_barcode_page.dart
│   │   ├── form_pendataan_page.dart
│   │   └── detail_lampu_page.dart
│   │
│   ├── widgets/
│   │   ├── project_card.dart
│   │   ├── area_card.dart
│   │   ├── lamp_card.dart
│   │   └── custom_button.dart
│   │
│   ├── models/
│   │   ├── user_model.dart
│   │   ├── project_model.dart
│   │   ├── area_model.dart
│   │   └── installation_model.dart
│   │
│   ├── services/
│   │   └── api_service.dart
│   │
│   └── utils/
│       ├── app_colors.dart
│       └── app_constants.dart
│
├── pubspec.yaml
└── README.md
```
