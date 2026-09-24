import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/profile/editable_profile_item.dart';
import 'package:mobile_teknisi/utils/app_colors.dart';

void main() {
  group('EditableProfileItem Phone Limit & Shake Tests', () {
    testWidgets('TextField locks at maxLength 13 characters, turns red, and shows error', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableProfileItem(
              icon: Icons.phone_outlined,
              title: 'Nomor Telepon',
              value: '08123456789',
              isEditable: true,
              isEditing: true,
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 13,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      expect(textFieldFinder, findsOneWidget);

      // Typing 13 chars is normal
      await tester.enterText(textFieldFinder, '0812345678901'); // 13 chars
      await tester.pumpAndSettle();
      expect(controller.text, '0812345678901');
      expect(find.text('Maksimal 13 karakter'), findsNothing);

      // Attempt typing 14 chars -> triggers shake and error
      await tester.enterText(textFieldFinder, '08123456789012'); // 14 chars
      await tester.pump();

      // Locked at 13 characters
      expect(controller.text, '0812345678901');
      expect(controller.text.length, 13);

      // Error message is displayed
      expect(find.text('Maksimal 13 karakter'), findsOneWidget);

      final TextField textField = tester.widget(textFieldFinder);
      expect(textField.style?.color, AppColors.error);

      // Auto-clear after 1.6s idle
      await tester.pump(const Duration(milliseconds: 1600));
      expect(find.text('Maksimal 13 karakter'), findsNothing);
      final TextField restoredField = tester.widget(textFieldFinder);
      expect(restoredField.style?.color, isNot(AppColors.error));
    });

    testWidgets('Clears error and red styling when backspacing below 13 characters', (tester) async {
      final controller = TextEditingController();
      final focusNode = FocusNode();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableProfileItem(
              icon: Icons.phone_outlined,
              title: 'Nomor Telepon',
              value: '08123456789',
              isEditable: true,
              isEditing: true,
              controller: controller,
              focusNode: focusNode,
              keyboardType: TextInputType.phone,
              maxLength: 13,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final textFieldFinder = find.byType(TextField);
      await tester.enterText(textFieldFinder, '08123456789012'); // 14 chars attempt
      await tester.pump();

      expect(find.text('Maksimal 13 karakter'), findsOneWidget);

      // Backspace to 12 chars
      await tester.enterText(textFieldFinder, '081234567890');
      await tester.pumpAndSettle();

      expect(find.text('Maksimal 13 karakter'), findsNothing);
    });
  });
}
