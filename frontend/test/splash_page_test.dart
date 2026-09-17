import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/splash/splash_page.dart';
import 'package:mobile_teknisi/utils/app_colors.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SplashPage Tests', () {
    testWidgets('renders splash page with AppColors.primary background and logo',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SplashPage(),
        ),
      );

      // Verify Scaffold has AppColors.primary as background
      final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
      expect(scaffold.backgroundColor, AppColors.primary);

      // Verify Image.asset exists targeting the correct logo asset
      final imageFinder = find.byType(Image);
      expect(imageFinder, findsOneWidget);

      final imageWidget = tester.widget<Image>(imageFinder);
      final assetImage = imageWidget.image as AssetImage;
      expect(assetImage.assetName, 'assets/images/logo bandell 1.png');
      expect(imageWidget.fit, BoxFit.contain);

      // Verify FadeTransition and ScaleTransition exist
      expect(find.byType(FadeTransition), findsOneWidget);
      expect(find.byType(ScaleTransition), findsOneWidget);
    });
  });
}

