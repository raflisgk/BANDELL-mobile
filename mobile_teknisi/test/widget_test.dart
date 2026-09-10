import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mobile_teknisi/models/notification_model.dart';
import 'package:mobile_teknisi/screens/detail_lampu/informasi_record_card.dart';
import 'package:mobile_teknisi/screens/history/history_lamp_card.dart';
import 'package:mobile_teknisi/screens/notification/notification_card.dart';

void main() {
  test('DateFormat id_ID initialization test', () async {
    await initializeDateFormatting('id_ID', null);
    final dt = DateTime.parse('2026-09-09T07:06:59.000Z');
    final formatted = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(dt.toLocal());
    expect(formatted.contains('September 2026'), isTrue);
  });

  testWidgets('InformasiRecordCard renders formatted dates and createdBy', (tester) async {
    await initializeDateFormatting('id_ID', null);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InformasiRecordCard(
            createdAt: '2026-09-09T07:06:59.000Z',
            updatedAt: '2026-09-09T07:06:59.000Z',
            createdBy: 'Budi Teknisi',
          ),
        ),
      ),
    );

    expect(find.text('Dibuat'), findsOneWidget);
    expect(find.text('Terakhir diperbarui'), findsOneWidget);
    expect(find.text('-'), findsOneWidget);
    expect(find.text('Budi Teknisi'), findsOneWidget);
  });

  testWidgets('InformasiRecordCard displays different updatedAt when edited', (tester) async {
    await initializeDateFormatting('id_ID', null);
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InformasiRecordCard(
            createdAt: '2026-09-09T07:06:59.000Z',
            updatedAt: '2026-09-09T08:20:00.000Z',
            createdBy: 'Budi Teknisi',
          ),
        ),
      ),
    );

    expect(find.text('-'), findsNothing);
    expect(find.text('Budi Teknisi'), findsOneWidget);
  });

  test('Filter date range rules calculation', () {
    final today = DateTime(2026, 9, 9);

    // Hari Ini
    final todayStart = today;
    final todayEnd = today;
    expect(todayStart.toIso8601String().split('T').first, '2026-09-09');
    expect(todayEnd.toIso8601String().split('T').first, '2026-09-09');

    // 7 Hari
    final sevenDaysStart = today.subtract(const Duration(days: 6));
    expect(sevenDaysStart.toIso8601String().split('T').first, '2026-09-03');
    expect(todayEnd.toIso8601String().split('T').first, '2026-09-09');

    // 1 Bulan
    final oneMonthStart = DateTime(today.year, today.month - 1, today.day);
    expect(oneMonthStart.toIso8601String().split('T').first, '2026-08-09');
    expect(todayEnd.toIso8601String().split('T').first, '2026-09-09');
  });

  testWidgets('HistoryLampCard formats raw ISO createdAt to dd MMM yyyy, HH:mm', (tester) async {
    await initializeDateFormatting('id_ID', null);
    final item = HistoryLampItem(
      userId: 1,
      projectId: 1,
      kode: 'LMP-001',
      jenis: 'LED 100W',
      status: 'Terpasang',
      isVerified: true,
      lokasi: 'Jl. Sudirman',
      koordinat: '-6.2, 106.8',
      fotoCount: '1 Foto',
      waktu: '2026-09-09T07:06:59.000000Z',
      createdAt: DateTime.parse('2026-09-09T07:06:59.000000Z'),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: HistoryLampCard(item: item),
        ),
      ),
    );

    final expectedFormatted = DateFormat('dd MMM yyyy, HH:mm', 'id_ID')
        .format(DateTime.parse('2026-09-09T07:06:59.000000Z').toLocal());
    expect(find.text(expectedFormatted), findsOneWidget);
  });

  test('NotificationModel.fromJson correctly parses assignment API data', () {
    final json = {
      'id': 111,
      'project_name': 'Sidoarjo',
      'district_name': 'Lingkar Timur',
      'notes': 'jalan gunung',
      'assigned_at': '2026-09-10T08:00:00.000000Z',
    };

    final model = NotificationModel.fromJson(json);

    expect(model.id, 111);
    expect(model.projectName, 'Sidoarjo');
    expect(model.districtName, 'Lingkar Timur');
    expect(model.notes, 'jalan gunung');
    expect(model.assignedAt, isNotNull);
    expect(model.title, 'Penugasan Project');
  });

  testWidgets('NotificationCard renders assignment details properly', (tester) async {
    await initializeDateFormatting('id_ID', null);

    final item = NotificationItem(
      id: 111,
      title: 'Penugasan Project',
      time: '15:54',
      content: '',
      projectName: 'Sidoarjo',
      districtName: 'Lingkar Timur',
      notes: 'jalan gunung',
      assignedAt: DateTime.parse('2026-09-10T08:00:00.000000Z'),
      isUnread: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: NotificationCard(notification: item),
        ),
      ),
    );

    expect(find.text('Penugasan Project'), findsOneWidget);
    expect(find.textContaining('Sidoarjo'), findsOneWidget);
    expect(find.textContaining('Lingkar Timur'), findsOneWidget);
    expect(find.textContaining('jalan gunung'), findsOneWidget);
    expect(find.textContaining('September 2026'), findsOneWidget);
  });
}
