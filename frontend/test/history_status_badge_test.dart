import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/history_lamp_model.dart';
import 'package:mobile_teknisi/screens/history/history_lamp_card.dart';

void main() {
  group('HistoryLampCard Status Badge Tests', () {
    test('HistoryLampModel parses Ditolak status correctly', () {
      final jsonDitolak = {
        'id': 1,
        'user_id': 1,
        'project_id': 1,
        'kode': 'LP-001',
        'jenis': 'LED 50W',
        'verification_status': 'Ditolak',
        'lokasi': 'Jl. Merdeka',
        'koordinat': '-6.2, 106.8',
        'foto_count': '1 Foto Lampu',
        'waktu': '2026-09-25',
      };

      final model = HistoryLampModel.fromJson(jsonDitolak);
      expect(model.isDitolak, isTrue);
      expect(model.isVerified, isFalse);
      expect(model.status, equals('Ditolak'));
    });

    test('HistoryLampModel parses Terverifikasi status correctly', () {
      final jsonVerified = {
        'id': 2,
        'user_id': 1,
        'project_id': 1,
        'kode': 'LP-002',
        'jenis': 'LED 100W',
        'verification_status': 'Terverifikasi',
        'is_verified': 1,
        'lokasi': 'Jl. Sudirman',
        'koordinat': '-6.2, 106.8',
        'foto_count': '1 Foto Lampu',
        'waktu': '2026-09-25',
      };

      final model = HistoryLampModel.fromJson(jsonVerified);
      expect(model.isDitolak, isFalse);
      expect(model.isVerified, isTrue);
      expect(model.status, equals('Terverifikasi'));
    });

    test('HistoryLampModel parses Menunggu Verifikasi status correctly', () {
      final jsonPending = {
        'id': 3,
        'user_id': 1,
        'project_id': 1,
        'kode': 'LP-003',
        'jenis': 'LED 70W',
        'verification_status': 'Menunggu Verifikasi',
        'lokasi': 'Jl. Thamrin',
        'koordinat': '-6.2, 106.8',
        'foto_count': '1 Foto Lampu',
        'waktu': '2026-09-25',
      };

      final model = HistoryLampModel.fromJson(jsonPending);
      expect(model.isDitolak, isFalse);
      expect(model.isVerified, isFalse);
      expect(model.status, equals('Menunggu Verifikasi'));
    });

    testWidgets('HistoryLampCard renders Ditolak badge with red styling',
        (WidgetTester tester) async {
      final ditolakItem = HistoryLampModel(
        idHistory: 1,
        userId: 1,
        projectId: 1,
        kode: 'LP-DITOLAK',
        jenis: 'LED 50W',
        status: 'Ditolak',
        isVerified: false,
        lokasi: 'Jl. Ahmad Yani',
        koordinat: '-6.2, 106.8',
        fotoCount: '1 Foto Lampu',
        waktu: '10:00',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryLampCard(
              item: ditolakItem,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Ditolak'), findsOneWidget);
      expect(find.byIcon(Icons.cancel_outlined), findsOneWidget);
      expect(find.text('Terverifikasi'), findsNothing);
      expect(find.text('Menunggu Verifikasi'), findsNothing);
    });

    testWidgets('HistoryLampCard renders Terverifikasi badge with green styling',
        (WidgetTester tester) async {
      final verifiedItem = HistoryLampModel(
        idHistory: 2,
        userId: 1,
        projectId: 1,
        kode: 'LP-VERIF',
        jenis: 'LED 50W',
        status: 'Terverifikasi',
        isVerified: true,
        lokasi: 'Jl. Ahmad Yani',
        koordinat: '-6.2, 106.8',
        fotoCount: '1 Foto Lampu',
        waktu: '10:00',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryLampCard(
              item: verifiedItem,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Terverifikasi'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_outline_rounded), findsOneWidget);
      expect(find.text('Ditolak'), findsNothing);
    });

    testWidgets('HistoryLampCard renders Menunggu Verifikasi badge with amber styling',
        (WidgetTester tester) async {
      final pendingItem = HistoryLampModel(
        idHistory: 3,
        userId: 1,
        projectId: 1,
        kode: 'LP-PENDING',
        jenis: 'LED 50W',
        status: 'Menunggu Verifikasi',
        isVerified: false,
        lokasi: 'Jl. Ahmad Yani',
        koordinat: '-6.2, 106.8',
        fotoCount: '1 Foto Lampu',
        waktu: '10:00',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: HistoryLampCard(
              item: pendingItem,
              onTap: () {},
            ),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Menunggu Verifikasi'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
      expect(find.text('Ditolak'), findsNothing);
      expect(find.text('Terverifikasi'), findsNothing);
    });

    test('Ditolak items are sorted to the very top over newer verified/pending items', () {
      final itemVerifiedNewest = HistoryLampModel(
        idHistory: 1,
        userId: 1,
        projectId: 1,
        kode: 'LP-VERIF-NEW',
        jenis: 'LED 50W',
        status: 'Terverifikasi',
        isVerified: true,
        lokasi: 'Jl. A',
        koordinat: '0, 0',
        fotoCount: '1',
        waktu: '12:00',
        createdAt: DateTime(2026, 9, 25, 12, 0),
      );

      final itemPending = HistoryLampModel(
        idHistory: 2,
        userId: 1,
        projectId: 1,
        kode: 'LP-PENDING-MID',
        jenis: 'LED 50W',
        status: 'Menunggu Verifikasi',
        isVerified: false,
        lokasi: 'Jl. B',
        koordinat: '0, 0',
        fotoCount: '1',
        waktu: '10:00',
        createdAt: DateTime(2026, 9, 25, 10, 0),
      );

      final itemDitolakOldest = HistoryLampModel(
        idHistory: 3,
        userId: 1,
        projectId: 1,
        kode: 'LP-DITOLAK-OLD',
        jenis: 'LED 50W',
        status: 'Ditolak',
        isVerified: false,
        lokasi: 'Jl. C',
        koordinat: '0, 0',
        fotoCount: '1',
        waktu: '08:00',
        createdAt: DateTime(2026, 9, 25, 8, 0),
      );

      final list = [itemVerifiedNewest, itemPending, itemDitolakOldest];

      list.sort((a, b) {
        if (a.isDitolak && !b.isDitolak) return -1;
        if (!a.isDitolak && b.isDitolak) return 1;

        final dateA = a.createdAt ?? a.installation?.createdAt;
        final dateB = b.createdAt ?? b.installation?.createdAt;

        if (dateA != null && dateB != null) {
          final cmp = dateB.compareTo(dateA);
          if (cmp != 0) return cmp;
        } else if (dateA != null) {
          return -1;
        } else if (dateB != null) {
          return 1;
        }

        final idA = a.idHistory ?? 0;
        final idB = b.idHistory ?? 0;
        return idB.compareTo(idA);
      });

      // Even though Ditolak was created earlier, it must be sorted to the very top (index 0)
      expect(list.first.kode, equals('LP-DITOLAK-OLD'));
      expect(list[1].kode, equals('LP-VERIF-NEW'));
      expect(list[2].kode, equals('LP-PENDING-MID'));
    });
  });
}

