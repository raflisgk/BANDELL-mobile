import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lottie/lottie.dart';
import 'package:mobile_teknisi/screens/notification/notification_page.dart';

void main() {
  testWidgets('Renders Lottie animation on NotificationPage empty state', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ScreenUtilInit(
        designSize: const Size(390, 844),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (context, child) => const MaterialApp(
          home: NotificationPage(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    // Settle after async loading completes (network will fail or return empty in test, leading to empty state or error)
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(NotificationPage), findsOneWidget);
    expect(find.byType(Lottie), findsOneWidget);
    expect(find.text('Belum Ada Notifikasi'), findsOneWidget);
  });
}
