# BANDELL Mobile Teknisi & API System

Repository terintegrasi untuk sistem operasional pendataan pemasangan lampu/panel PJU BANDELL.

## Struktur Project

```text
mobile_teknisi/
│
├── frontend/           # Aplikasi Mobile Flutter (Android) untuk Teknisi Lapangan
│   ├── android/
│   ├── assets/
│   ├── lib/
│   ├── test/
│   ├── windows/
│   ├── pubspec.yaml
│   └── README.md
│
├── backend/            # Headless REST API berbasis Laravel
│   ├── app/
│   ├── bootstrap/
│   ├── config/
│   ├── database/
│   ├── public/
│   ├── resources/
│   ├── routes/
│   ├── storage/
│   ├── tests/
│   ├── vendor/
│   ├── artisan
│   └── composer.json
│
├── postman/            # Postman Collections, Environments, dan API specs
│   ├── collections/
│   ├── documents/
│   ├── environments/
│   ├── flows/
│   ├── globals/
│   ├── mocks/
│   └── specs/
│
├── docs/               # Dokumentasi Teknis Project
│   ├── api/            # Spesifikasi dan dokumentasi endpoint
│   ├── database/       # Skema dan relasi database
│   └── diagrams/       # Diagram alur & arsitektur
│
└── README.md           # Dokumentasi Utama
```

---

## Panduan Memulai

### 1. Menjalankan Backend (Laravel API)
```bash
cd backend
php artisan serve --host=0.0.0.0 --port=8000
```
- Endpoint root: `http://localhost:8000/`
- API Base URL: `http://localhost:8000/api`

### 2. Menjalankan Frontend (Flutter Mobile Teknisi)
```bash
cd frontend
flutter pub get
flutter run
```

Untuk build release APK:
```bash
cd frontend
flutter build apk --release
```

### 3. Testing API (Postman)
Buka aplikasi Postman dan import workspace/collection yang tersedia di folder `postman/`.
