import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/splash/splash_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashPage Tests', () {
    testWidgets('reveals the Pilar wordmark after its monogram',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, const Color(0xFF0F58B7));
      expect(find.text('P'), findsOneWidget);
      expect(find.text('Pilar'), findsNothing);

      await tester.pump(const Duration(seconds: 6));
      expect(find.text('Pilar'), findsOneWidget);
    });
  });
}
