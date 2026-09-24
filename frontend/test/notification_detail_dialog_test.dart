import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/notification_model.dart';
import 'package:mobile_teknisi/screens/notification/notification_detail_dialog.dart';

void main() {
  group('NotificationModel & DetailDialog Tests', () {
    test('NotificationModel correctly parses assignment JSON', () {
      final json = {
        'id': 52,
        'type': 'assignment',
        'title': 'Penugasan Baru Diterima',
        'project_id': 2,
        'project_name': 'Gresik',
        'notes': 'Harap prioritaskan titik lampu',
        'assigned_at': '2026-09-23T15:03:00+00:00',
        'created_at': '2026-09-23T15:03:00+00:00',
      };

      final notif = NotificationModel.fromJson(json);

      expect(notif.type, NotificationType.assignment);
      expect(notif.projectName, 'Gresik');
      expect(notif.notes, 'Harap prioritaskan titik lampu');
    });

    test('NotificationModel correctly parses rejected JSON with installation', () {
      final json = {
        'id': 100001,
        'type': 'rejected',
        'title': 'Laporan Ditolak',
        'project_id': 1,
        'project_name': 'Surabaya',
        'installation_id': 1,
        'installation': {
          'id': 1,
          'id_installation': 1,
          'verification_status': 'Ditolak',
          'district': 'Tegalsari',
          'id_lcu': 'SBY-001',
          'note_by_admin': 'Foto barcode tiang tidak terbaca jelas.',
        },
        'is_read': false,
      };

      final notif = NotificationModel.fromJson(json);

      expect(notif.type, NotificationType.rejected);
      expect(notif.projectName, 'Surabaya');
      expect(notif.district, 'Tegalsari');
      expect(notif.idLcu, 'SBY-001');
      expect(notif.installation, isNotNull);
      expect(notif.installation?.note_by_admin, 'Foto barcode tiang tidak terbaca jelas.');
    });

    testWidgets('DetailDialog renders assignment details correctly', (tester) async {
      final notif = NotificationModel(
        id: 1,
        type: NotificationType.assignment,
        title: 'Penugasan Baru Diterima',
        projectName: 'Proyek Jakarta',
        notes: 'Harap prioritaskan titik lampu sepanjang Jl. Fatmawati.',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => NotificationDetailDialog.show(context, notification: notif),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('Detail Penugasan'), findsOneWidget);
      expect(find.text('NAMA PROYEK'), findsOneWidget);
      expect(find.text('Proyek Jakarta'), findsOneWidget);
      expect(find.text('CATATAN'), findsOneWidget);
      expect(find.text('Harap prioritaskan titik lampu sepanjang Jl. Fatmawati.'), findsOneWidget);
      expect(find.text('Tutup'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Penugasan'), findsNothing);
    });

    testWidgets('DetailDialog renders rejected details matching reference UI', (tester) async {
      final notif = NotificationModel.fromJson({
        'id': 2,
        'type': 'rejected',
        'title': 'Laporan Ditolak',
        'project_name': 'Bekasi',
        'installation_id': 1,
        'installation': {
          'id': 1,
          'id_installation': 1,
          'verification_status': 'Ditolak',
          'district': 'Jakarta Selatan',
          'id_lcu': 'JKT-003',
          'note_by_admin': 'Foto barcode tiang tidak terbaca jelas dan koordinat GPS melenceng lebih dari 50 meter. Mohon lakukan verifikasi ulang di lokasi sebelum submit ulang data.',
        },
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => NotificationDetailDialog.show(context, notification: notif),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      // 1. Header
      expect(find.text('Detail Laporan Ditolak'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);

      // 2. Card Nama Proyek
      expect(find.text('NAMA PROYEK'), findsOneWidget);
      expect(find.text('Bekasi'), findsOneWidget);

      // 3. Detail Pemasangan
      expect(find.text('DETAIL PEMASANGAN'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
      expect(find.text('Jakarta Selatan'), findsOneWidget);
      expect(find.text('JKT-003'), findsOneWidget);

      // 4. Catatan (from installation.note_by_admin)
      expect(find.text('CATATAN'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
      expect(
        find.text('Foto barcode tiang tidak terbaca jelas dan koordinat GPS melenceng lebih dari 50 meter. Mohon lakukan verifikasi ulang di lokasi sebelum submit ulang data.'),
        findsOneWidget,
      );

      // 5. Button Tutup
      expect(find.text('Tutup'), findsOneWidget);

      await tester.tap(find.text('Tutup'));
      await tester.pumpAndSettle();
      expect(find.text('Detail Laporan Ditolak'), findsNothing);
    });

    testWidgets('DetailDialog fallback values when installation data is missing/empty', (tester) async {
      final notif = NotificationModel.fromJson({
        'id': 3,
        'type': 'rejected',
        'title': 'Laporan Ditolak',
        'project_name': '-',
        'installation_id': 1,
        'installation': {
          'id': 1,
          'id_installation': 1,
        },
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () => NotificationDetailDialog.show(context, notification: notif),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text('DETAIL PEMASANGAN'), findsOneWidget);
      expect(find.text('-'), findsNWidgets(2)); // district is '-', idLcu is '-'
      expect(find.text('Tidak ada catatan.'), findsOneWidget);
    });
  });
}
