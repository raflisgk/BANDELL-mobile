import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/user_model.dart';
import 'package:mobile_teknisi/screens/profile/profile_page.dart';
import 'package:mobile_teknisi/services/auth_service.dart';

void main() {
  setUp(() {
    AuthService.currentUser = UserModel(
      idUser: 1,
      name: 'Budi Santoso',
      username: 'budi',
      role: 'Teknisi Lapangan',
      email: 'budi@example.com',
      phone: '081234567890',
      placementArea: 'Area Jakarta Barat',
    );
  });

  Widget buildTestWidget() {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) => const MaterialApp(home: ProfilePage()),
    );
  }

  group('ProfilePage Comprehensive Responsive Tests (flutter_screenutil)', () {
    testWidgets(
      'Small screen (360x640): no overflow, all elements render cleanly',
      (tester) async {
        tester.view.physicalSize = const Size(360, 640);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Budi Santoso'), findsWidgets);
        expect(find.text('budi@example.com'), findsWidgets);
        expect(find.text('Nomor Telepon'), findsOneWidget);
        expect(find.text('Lokasi'), findsOneWidget);
        expect(find.text('Notifikasi'), findsOneWidget);
        expect(find.text('Keluar'), findsOneWidget);
      },
    );

    testWidgets(
      'Standard Medium screen (360x740): no overflow, Keluar & Notifikasi visible',
      (tester) async {
        tester.view.physicalSize = const Size(360, 740);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Keluar'), findsOneWidget);
        expect(find.text('Notifikasi'), findsOneWidget);
      },
    );

    testWidgets(
      'Popular Medium-Tall screen (390x844): fixed layout fits full screen perfectly',
      (tester) async {
        tester.view.physicalSize = const Size(390, 844);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Budi Santoso'), findsWidgets);
        expect(find.text('Keluar'), findsOneWidget);
        expect(find.text('Versi Aplikasi v1.0.0'), findsOneWidget);
      },
    );

    testWidgets(
      'Tall screen (412x915): elements scale proportionally with no empty gaps',
      (tester) async {
        tester.view.physicalSize = const Size(412, 915);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Keluar'), findsOneWidget);
        expect(find.text('Versi Aplikasi v1.0.0'), findsOneWidget);
      },
    );

    testWidgets(
      'Extra Large screen (430x932): renders proportional layout without issues',
      (tester) async {
        tester.view.physicalSize = const Size(430, 932);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(buildTestWidget());
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('Keluar'), findsOneWidget);
      },
    );
  });
}
