import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/manual/manual_page.dart';
import 'package:mobile_teknisi/utils/app_colors.dart';

void main() {
  group('Manual Barcode Validation & Shake Tests', () {
    testWidgets('Entering up to 11 characters is normal and does not trigger error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualPage(idProject: 1, idArea: 1),
        ),
      );
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField).first;
      await tester.enterText(textFieldFinder, '12345678901'); // 11 chars
      await tester.pumpAndSettle();

      expect(find.text('Maksimal 11 karakter'), findsNothing);

      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.controller?.text, '12345678901');
      expect(textField.style?.color, isNot(AppColors.error));
    });

    testWidgets('Attempting 12th character locks at 11, triggers shake, turns red, and shows error', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualPage(idProject: 1, idArea: 1),
        ),
      );
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField).first;
      // First 11 chars
      await tester.enterText(textFieldFinder, '12345678901');
      await tester.pumpAndSettle();

      // Attempt 12th char
      await tester.enterText(textFieldFinder, '123456789012');
      await tester.pump();

      // Field is locked at 11 chars
      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.controller?.text, '12345678901');

      // Error message is displayed
      expect(find.text('Maksimal 11 karakter'), findsOneWidget);

      // Text color is red
      expect(textField.style?.color, AppColors.error);

      // Let animation finish
      await tester.pumpAndSettle();
      expect(textField.controller?.text, '12345678901');

      // Backspace to 10 chars -> returns to normal
      await tester.enterText(textFieldFinder, '1234567890');
      await tester.pumpAndSettle();

      expect(find.text('Maksimal 11 karakter'), findsNothing);
      final TextField restoredField = tester.widget(textFieldFinder);
      expect(restoredField.style?.color, isNot(AppColors.error));
    });

    testWidgets('Error message and red color auto-clear after user stops typing', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualPage(idProject: 1, idArea: 1),
        ),
      );
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField).first;
      await tester.enterText(textFieldFinder, '123456789012'); // exceeds limit
      await tester.pump();

      expect(find.text('Maksimal 11 karakter'), findsOneWidget);

      // Advance time by 1.6 seconds (user stops typing)
      await tester.pump(const Duration(milliseconds: 1600));

      expect(find.text('Maksimal 11 karakter'), findsNothing);
      final TextField restoredField = tester.widget(textFieldFinder);
      expect(restoredField.style?.color, isNot(AppColors.error));
    });

    testWidgets('Error message and red color clear when moving focus to another textbox', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualPage(idProject: 1, idArea: 1),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      final barcodeField = textFields.at(0);
      final panelCodeField = textFields.at(1);

      await tester.enterText(barcodeField, '123456789012'); // exceeds limit
      await tester.pump();

      expect(find.text('Maksimal 11 karakter'), findsOneWidget);

      // Tap second text field (move textbox)
      await tester.tap(panelCodeField);
      await tester.pump();

      expect(find.text('Maksimal 11 karakter'), findsNothing);
      final TextField restoredField = tester.widget(barcodeField);
      expect(restoredField.style?.color, isNot(AppColors.error));
    });

    testWidgets('Latitude locks at 10 chars, triggers error styling, and auto-clears on idle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualPage(idProject: 1, idArea: 1),
        ),
      );
      await tester.pumpAndSettle();

      final latFinder = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Latitude',
      );
      expect(latFinder, findsOneWidget);

      // Typing 10 chars is normal
      await tester.enterText(latFinder, '-6.1234567'); // 10 chars
      await tester.pumpAndSettle();
      expect(find.text('Maksimal 10 karakter'), findsNothing);

      // Attempt 11th char
      await tester.enterText(latFinder, '-6.12345678');
      await tester.pump();

      // Field is locked at 10 chars
      final TextField latField = tester.widget(latFinder);
      expect(latField.controller?.text, '-6.1234567');
      expect(latField.style?.color, AppColors.error);
      expect(find.text('Maksimal 10 karakter'), findsOneWidget);

      // Idle for 1.6s -> auto-clears error and red style
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('Maksimal 10 karakter'), findsNothing);
      final TextField restoredLatField = tester.widget(latFinder);
      expect(restoredLatField.style?.color, isNot(AppColors.error));
    });

    testWidgets('Longitude locks at 11 chars, triggers error styling, and auto-clears on unfocus', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: ManualPage(idProject: 1, idArea: 1),
        ),
      );
      await tester.pumpAndSettle();

      final lngFinder = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Longitude',
      );
      final latFinder = find.byWidgetPredicate(
        (w) => w is TextField && w.decoration?.hintText == 'Latitude',
      );
      expect(lngFinder, findsOneWidget);

      // Typing 11 chars is normal
      await tester.enterText(lngFinder, '106.1234567'); // 11 chars
      await tester.pumpAndSettle();
      expect(find.text('Maksimal 11 karakter'), findsNothing);

      // Attempt 12th char
      await tester.enterText(lngFinder, '106.12345678');
      await tester.pump();

      // Field is locked at 11 chars
      final TextField lngField = tester.widget(lngFinder);
      expect(lngField.controller?.text, '106.1234567');
      expect(lngField.style?.color, AppColors.error);
      expect(find.text('Maksimal 11 karakter'), findsOneWidget);

      // Move focus to another field
      await tester.tap(latFinder);
      await tester.pump();

      expect(find.text('Maksimal 11 karakter'), findsNothing);
      final TextField restoredLngField = tester.widget(lngFinder);
      expect(restoredLngField.style?.color, isNot(AppColors.error));
    });
  });
}

