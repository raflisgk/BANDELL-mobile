import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_teknisi/screens/splash/splash_page.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashPage Tests', () {
    testWidgets('renders BANDELL Mobile splash screen with white background and animation',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, Colors.white);
      expect(find.byType(Lottie), findsOneWidget);
    });
  });
}

