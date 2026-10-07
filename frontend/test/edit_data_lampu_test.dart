import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/edit_data_lampu/edit_data_lampu_page.dart';
import 'package:mobile_teknisi/screens/edit_data_lampu/edit_lampu_type.dart';
import 'package:mobile_teknisi/widgets/catatan.dart';
import 'package:mobile_teknisi/widgets/dokumentasi.dart';

void main() {
  group('EditDataLampuPage UI Tests', () {
    testWidgets('Renders Catatan between EditLampuType and Dokumentasi', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            initialKodeLampu: 'LP-TEST-001',
            initialCatatan: 'Kondisi tiang miring sedikit',
            initialTipeLampu: 'LED 50W',
            initialPhotos: [],
          ),
        ),
      );
      await tester.pump();

      // Verify Catatan exists and is rendered
      expect(find.byType(Catatan), findsOneWidget);
      expect(find.text('Kondisi tiang miring sedikit'), findsOneWidget);

      // Verify EditLampuType and Dokumentasi also exist
      expect(find.byType(EditLampuType), findsOneWidget);
      expect(find.byType(Dokumentasi), findsOneWidget);

      // Verify Catatan is rendered between EditLampuType and Dokumentasi vertically
      final typeRect = tester.getRect(find.byType(EditLampuType));
      final catatanRect = tester.getRect(find.byType(Catatan));
      final dokumentasiRect = tester.getRect(find.byType(Dokumentasi));

      expect(catatanRect.top, greaterThanOrEqualTo(typeRect.bottom));
      expect(dokumentasiRect.top, greaterThanOrEqualTo(catatanRect.bottom));
    });

    testWidgets('When no photos are uploaded, no photo items are shown', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            initialKodeLampu: 'LP-TEST-002',
            initialPhotos: [],
          ),
        ),
      );
      await tester.pump();

      // In Dokumentasi, when photos is empty, + Tambah Foto is shown but no delete buttons
      expect(find.byType(Dokumentasi), findsOneWidget);
      expect(find.text('Tambah Foto'), findsOneWidget);
      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets(
      'When photos are uploaded, photo items are shown with remove buttons',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: EditDataLampuPage(
              isEdit: true,
              initialKodeLampu: 'LP-TEST-003',
              initialPhotos: [
                'https://example.com/lamp1.jpg',
                'https://example.com/lamp2.jpg',
              ],
            ),
          ),
        );
        await tester.pump();

        expect(find.byType(Dokumentasi), findsOneWidget);
        // Two close/remove icons for the two photos
        expect(find.byIcon(Icons.close_rounded), findsNWidgets(2));
      },
    );

    testWidgets('Tapping remove button shows confirmation dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            initialKodeLampu: 'LP-TEST-004',
            initialPhotos: ['https://example.com/lamp1.jpg'],
          ),
        ),
      );
      await tester.pump();

      // Scroll Dokumentasi into view because standard test viewport is 800x600
      await tester.ensureVisible(find.byType(Dokumentasi));
      await tester.pumpAndSettle();

      // Tap remove button
      await tester.tap(find.byIcon(Icons.close_rounded).first);
      await tester.pumpAndSettle();

      // Verify confirmation dialog appears
      expect(find.text('Hapus Foto?'), findsOneWidget);
      expect(
        find.text('Apakah Anda yakin ingin menghapus foto dokumentasi ini?'),
        findsOneWidget,
      );
      expect(find.widgetWithText(TextButton, 'Batal'), findsOneWidget);
      expect(find.text('Hapus'), findsOneWidget);

      // Tap Batal on dialog closes dialog without removing
      await tester.tap(find.widgetWithText(TextButton, 'Batal'));
      await tester.pumpAndSettle();
      expect(find.text('Hapus Foto?'), findsNothing);
    });

    testWidgets('Tapping photo thumbnail opens preview dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            initialKodeLampu: 'LP-TEST-005',
            initialPhotos: ['https://example.com/lamp1.jpg'],
          ),
        ),
      );
      await tester.pump();

      // Scroll Dokumentasi into view
      await tester.ensureVisible(find.byType(Dokumentasi));
      await tester.pumpAndSettle();

      // Tap the photo item (not delete icon)
      await tester.tap(find.byType(ClipRRect).first);
      await tester.pumpAndSettle();

      // Verify preview dialog is visible
      expect(find.text('Preview Foto'), findsOneWidget);
      expect(find.byType(InteractiveViewer), findsOneWidget);

      // Close preview dialog
      await tester.tap(find.byIcon(Icons.close_rounded).last);
      await tester.pumpAndSettle();
      expect(find.text('Preview Foto'), findsNothing);
    });

    testWidgets('Empty Kode Lampu triggers validation error and prevents saving',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            idInstallation: 1,
            initialKodeLampu: '',
            initialLatitude: '-6.2088',
            initialLongitude: '106.8456',
            initialPhotos: [],
          ),
        ),
      );
      await tester.pump();

      final saveBtn = find.text('Simpan Perubahan');
      await tester.ensureVisible(saveBtn);
      await tester.pumpAndSettle();
      await tester.tap(saveBtn);
      await tester.pumpAndSettle();

      expect(find.text('Kode lampu wajib diisi.'), findsOneWidget);
    });

    testWidgets('Kode Lampu is limited to maximum 12 characters when typing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            idInstallation: 1,
            initialKodeLampu: '',
            initialLatitude: '-6.2088',
            initialLongitude: '106.8456',
            initialPhotos: [],
          ),
        ),
      );
      await tester.pump();

      final textField = find.byType(TextField).first;
      await tester.enterText(textField, '123456789012345');
      await tester.pump();

      expect(find.text('123456789012'), findsOneWidget);
    });

    testWidgets('Required asterisk (*) is displayed next to Kode Lampu',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            initialKodeLampu: 'LP-TEST-006',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Kode Lampu'), findsOneWidget);
      expect(find.text('*'), findsWidgets);
    });
  });
}
