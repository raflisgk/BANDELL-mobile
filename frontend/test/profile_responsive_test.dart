import 'package:flutter/material.dart';
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

  group('ProfilePage Comprehensive Responsive Tests', () {
    testWidgets('Ultra small screen (320x568): no overflow, scrolls normally, Keluar reachable', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.maxScrollExtent, greaterThan(0.0));
      expect(scrollable.position.physics, isA<ClampingScrollPhysics>());

      await tester.drag(find.byType(Scrollable), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('Small screen (360x640): no overflow, Surel and Keluar render cleanly', (tester) async {
      tester.view.physicalSize = const Size(360, 640);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('Surel'), findsOneWidget);
      expect(find.text('Nama Lengkap'), findsOneWidget);
      expect(find.text('Nomor Telepon'), findsOneWidget);
      expect(find.text('Lokasi'), findsOneWidget);

      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      debugPrint('360x640 maxScrollExtent: ${scrollable.position.maxScrollExtent}');
      if (scrollable.position.maxScrollExtent > 0) {
        await tester.drag(find.byType(Scrollable), const Offset(0, -200));
        await tester.pumpAndSettle();
      }
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('Standard Medium screen (360x740): no overflow, Keluar reachable', (tester) async {
      tester.view.physicalSize = const Size(360, 740);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      debugPrint('360x740 maxScrollExtent: ${scrollable.position.maxScrollExtent}');
      if (scrollable.position.maxScrollExtent > 0) {
        await tester.drag(find.byType(Scrollable), const Offset(0, -200));
        await tester.pumpAndSettle();
      }
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('Popular Medium-Tall screen (390x844): card hugs content without extra whitespace', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      debugPrint('390x844 maxScrollExtent: ${scrollable.position.maxScrollExtent}');
      expect(scrollable.position.maxScrollExtent, 0.0);
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('Tall screen (412x915): card hugs content naturally, no extra expansion', (tester) async {
      tester.view.physicalSize = const Size(412, 915);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      debugPrint('412x915 maxScrollExtent: ${scrollable.position.maxScrollExtent}');
      expect(scrollable.position.maxScrollExtent, 0.0);
      expect(find.text('Keluar'), findsOneWidget);
    });

    testWidgets('Landscape screen (844x390): handles scrolling gracefully with no RenderFlex overflow', (tester) async {
      tester.view.physicalSize = const Size(844, 390);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(const MaterialApp(home: ProfilePage()));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
      expect(scrollable.position.maxScrollExtent, greaterThan(0.0));

      await tester.drag(find.byType(Scrollable), const Offset(0, -400));
      await tester.pumpAndSettle();
      expect(find.text('Keluar'), findsOneWidget);
    });
  });
}

