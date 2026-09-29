import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/notification_model.dart';
import 'package:mobile_teknisi/screens/notification/notification_card.dart';

void main() {
  group('NotificationCard Expandable Tests', () {
    testWidgets('Assignment card collapsed does not show expanded details', (
      tester,
    ) async {
      final notif = NotificationModel(
        id: 1,
        title: 'Penugasan Baru Diterima',
        projectName: 'Proyek Surabaya',
        message: 'Anda telah ditugaskan untuk proyek Surabaya.',
        time: '3 jam yang lalu',
        notes: 'Harap selesaikan sebelum jam 5 sore',
        isUnread: true,
        type: NotificationType.assignment,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(notification: notif, isExpanded: false),
          ),
        ),
      );

      // Collapsed: summary text and badge are visible
      expect(find.text('Penugasan Baru Diterima'), findsOneWidget);
      expect(find.text('Penugasan'), findsOneWidget);
      expect(find.text('3 jam yang lalu'), findsOneWidget);
      expect(
        find.text('Anda telah ditugaskan untuk proyek Surabaya.'),
        findsOneWidget,
      );

      // Expanded details should NOT be visible when collapsed
      expect(find.text('NAMA PROYEK'), findsNothing);
      expect(find.text('CATATAN KHUSUS'), findsNothing);
      // Ensure no quick action button exists
      expect(find.text('Buka Proyek Ini'), findsNothing);
      expect(find.text('Pilih Proyek Ini'), findsNothing);
    });

    testWidgets(
      'Assignment card expanded shows project and notes without waktu penugasan in detail',
      (tester) async {
        final notif = NotificationModel(
          id: 1,
          title: 'Penugasan Baru Diterima',
          projectName: 'Proyek Sidoarjo',
          message: 'Anda telah ditugaskan untuk proyek Sidoarjo.',
          time: '2 jam yang lalu',
          notes: 'Pastikan bawa tangga tambahan',
          isUnread: false,
          assignedAt: DateTime(2026, 9, 29, 10, 30),
          type: NotificationType.assignment,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: NotificationCard(notification: notif, isExpanded: true),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Expanded details must be visible
        expect(find.text('NAMA PROYEK'), findsOneWidget);
        expect(find.text('Proyek Sidoarjo'), findsOneWidget);
        expect(find.text('CATATAN KHUSUS'), findsOneWidget);
        expect(find.text('Pastikan bawa tangga tambahan'), findsOneWidget);
        // Ensure Waktu Penugasan is NOT present in detail
        expect(find.textContaining('Waktu Penugasan'), findsNothing);

        // Absolutely NO quick action buttons
        expect(find.text('Buka Proyek Ini'), findsNothing);
        expect(find.text('Pilih Proyek Ini'), findsNothing);
      },
    );

    testWidgets('Rejected card expanded shows rejected details and reason', (
      tester,
    ) async {
      final notif = NotificationModel(
        id: 2,
        title: 'Laporan Ditolak',
        projectName: 'Proyek Gresik',
        message: 'Laporan penugasan ditolak.',
        time: '5 jam yang lalu',
        notes: 'Foto tiang kurang jelas',
        isUnread: true,
        type: NotificationType.rejected,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(notification: notif, isExpanded: true),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Expanded rejected details must be visible
      expect(find.text('STATUS LAPORAN: DITOLAK'), findsOneWidget);
      expect(find.text('DETAIL PEMASANGAN'), findsOneWidget);
      expect(find.text('ALASAN PENOLAKAN DARI ADMIN'), findsOneWidget);
      expect(find.text('Foto tiang kurang jelas'), findsOneWidget);

      // Absolutely NO quick action buttons
      expect(find.text('Buka Proyek Ini'), findsNothing);
      expect(find.text('Pilih Proyek Ini'), findsNothing);
    });

    testWidgets('Tapping card invokes onTap callback without opening Dialog', (
      tester,
    ) async {
      bool tapped = false;
      final notif = NotificationModel(
        id: 3,
        title: 'Penugasan Baru Diterima',
        projectName: 'Proyek Malang',
        message: 'Anda telah ditugaskan.',
        isUnread: true,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: NotificationCard(
              notification: notif,
              isExpanded: false,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(NotificationCard));
      await tester.pumpAndSettle();

      expect(tapped, isTrue);
      // Verify no Dialog appeared in widget tree
      expect(find.byType(Dialog), findsNothing);
    });
  });
}
