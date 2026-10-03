import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/login/login_page.dart';

void main() {
  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MaterialApp(home: LoginPage()),
    );
  }

  group('LoginPage Responsive & Layout Tests', () {
    testWidgets('Renders all login widgets without error', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(buildTestWidget());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('BANDELL'), findsOneWidget);
      expect(find.text('Silakan login untuk melanjutkan'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
    });
  });
}
