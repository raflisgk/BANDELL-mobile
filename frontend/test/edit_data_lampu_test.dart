import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/edit_data_lampu/edit_data_lampu_page.dart';
import 'package:mobile_teknisi/screens/edit_data_lampu/edit_lampu_type.dart';
import 'package:mobile_teknisi/widgets/catatan.dart';
import 'package:mobile_teknisi/widgets/dokumentasi.dart';

void main() {
  group('EditDataLampuPage UI Tests', () {
    testWidgets('Renders Catatan between EditLampuType and Dokumentasi',
        (WidgetTester tester) async {
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

    testWidgets('When no photos are uploaded, no photo items are shown',
        (WidgetTester tester) async {
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

    testWidgets('When photos are uploaded, photo items are shown with remove buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: EditDataLampuPage(
            isEdit: true,
            initialKodeLampu: 'LP-TEST-003',
            initialPhotos: ['https://example.com/lamp1.jpg', 'https://example.com/lamp2.jpg'],
          ),
        ),
      );
      await tester.pump();

      expect(find.byType(Dokumentasi), findsOneWidget);
      // Two close/remove icons for the two photos
      expect(find.byIcon(Icons.close_rounded), findsNWidgets(2));
    });
  });
}
