import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/installation_model.dart';
import 'package:mobile_teknisi/screens/detail_lampu/detail_lampu_page.dart';

void main() {
  group('DetailLampuPage Tests', () {
    testWidgets('Renders DetailLampuPage with minimal arguments without throwing',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: DetailLampuPage(
            lampCode: 'LP-TEST-001',
          ),
        ),
      );
      await tester.pump();

      expect(find.text('LP-TEST-001'), findsWidgets);
    });

    testWidgets('Renders DetailLampuPage with installation model',
        (WidgetTester tester) async {
      final model = InstallationModel(
        idInstallation: 10,
        idArea: 1,
        lampCode: 'LP-002',
        lampType: 'LED 100W',
        photos: ['https://example.com/photo1.jpg'],
        notes: 'Catatan tiang',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DetailLampuPage(
            idInstallation: 10,
            installation: model,
          ),
        ),
      );
      await tester.pump();

      expect(find.text('LP-002'), findsWidgets);
      expect(find.text('LED 100W'), findsWidgets);
    });

    testWidgets('Tapping Edit Data navigates without crashing',
        (WidgetTester tester) async {
      final model = InstallationModel(
        idInstallation: 10,
        idArea: 1,
        lampCode: 'LP-002',
        lampType: 'LED 100W',
        photos: ['https://example.com/photo1.jpg'],
        notes: 'Catatan tiang',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: DetailLampuPage(
            idInstallation: 10,
            installation: model,
          ),
        ),
      );
      await tester.pump();

      // Find and tap Edit Data button
      final editButton = find.text('Edit Data');
      expect(editButton, findsOneWidget);

      await tester.ensureVisible(editButton);
      await tester.pumpAndSettle();
      await tester.tap(editButton);
      await tester.pumpAndSettle();

      // Verify Edit Data page is displayed
      expect(find.text('Edit Data'), findsWidgets);
      expect(find.text('Catatan tiang'), findsOneWidget);
    });
  });
}
