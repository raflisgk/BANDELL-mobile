import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/widgets/pilih_tanggal.dart';

void main() {
  group('PilihTanggal Single & Range Tests', () {
    testWidgets('Opens PilihTanggal single mode on tap, shows month, weekdays, and single day selection', (tester) async {
      DateTime? chosenDate;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TanggalPemasangan(
              selectedDate: DateTime(2026, 5, 20),
              onDateSelected: (date) {
                chosenDate = date;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Field displays initial date formatted dd/MM/yyyy
      expect(find.text('20/05/2026'), findsOneWidget);
      expect(find.text('Tanggal Penugasan'), findsOneWidget);

      // Tap the date field to open modal
      await tester.tap(find.text('20/05/2026'));
      await tester.pumpAndSettle();

      // PilihTanggal modal is displayed
      expect(find.byType(PilihTanggal), findsOneWidget);
      expect(find.text('Mei 2026'), findsOneWidget);

      // Weekday headers
      expect(find.text('Sen'), findsOneWidget);
      expect(find.text('Sel'), findsOneWidget);
      expect(find.text('Rab'), findsOneWidget);
      expect(find.text('Kam'), findsOneWidget);
      expect(find.text('Jum'), findsOneWidget);
      expect(find.text('Sab'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);

      // Sunday (Min) text color is red
      final Text sundayText = tester.widget(find.text('Min'));
      expect(sundayText.style?.color, const Color(0xFFDC2626));

      // 20 is initially selected in Mei 2026
      // Tap another date: 22
      await tester.tap(find.text('22'));
      await tester.pumpAndSettle();

      // Click "Pilih"
      await tester.tap(find.text('Pilih'));
      await tester.pumpAndSettle();

      // Modal is closed
      expect(find.byType(PilihTanggal), findsNothing);

      // chosenDate is updated to May 22, 2026
      expect(chosenDate, DateTime(2026, 5, 22));
    });

    testWidgets('Month navigation buttons work (< and >)', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PilihTanggal(
              initialStartDate: DateTime(2026, 5, 20),
              isSingleDate: true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Mei 2026'), findsOneWidget);

      // Tap previous month (<)
      await tester.tap(find.byIcon(Icons.chevron_left_rounded));
      await tester.pumpAndSettle();
      expect(find.text('April 2026'), findsOneWidget);

      // Tap next month (>) twice
      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Mei 2026'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.chevron_right_rounded));
      await tester.pumpAndSettle();
      expect(find.text('Juni 2026'), findsOneWidget);
    });

    testWidgets('Tapping Batal closes modal without selecting new date', (tester) async {
      DateTime? chosenDate = DateTime(2026, 5, 20);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TanggalPemasangan(
              selectedDate: chosenDate,
              onDateSelected: (date) {
                chosenDate = date;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('20/05/2026'));
      await tester.pumpAndSettle();

      // Tap date 15
      await tester.tap(find.text('15'));
      await tester.pumpAndSettle();

      // Tap Batal
      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.byType(PilihTanggal), findsNothing);
      // chosenDate remains unchanged
      expect(chosenDate, DateTime(2026, 5, 20));
    });
  });
}
