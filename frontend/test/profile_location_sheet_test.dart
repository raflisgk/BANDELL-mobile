import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/user_model.dart';
import 'package:mobile_teknisi/screens/profile/profile_page.dart';
import 'package:mobile_teknisi/services/auth_service.dart';

void main() {
  testWidgets(
    'Location chips show max 3 and +N when > 3 locations, and shows Tooltip on tap',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      AuthService.currentUser = UserModel(
        idUser: 1,
        name: 'Budi Santoso',
        username: 'budi',
        role: 'Teknisi Lapangan',
        email: 'budi@example.com',
        phone: '081234567890',
        placementArea: 'Area Jakarta Barat, Area Jakarta Pusat, Area Jakarta Selatan, Area Jakarta Timur, Area Depok',
      );

      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(390, 844),
          builder: (context, child) => const MaterialApp(home: ProfilePage()),
        ),
      );
      await tester.pumpAndSettle();

      // Verify the first 3 locations are shown
      expect(find.text('Area Jakarta Barat'), findsOneWidget);
      expect(find.text('Area Jakarta Pusat'), findsOneWidget);
      expect(find.text('Area Jakarta Selatan'), findsOneWidget);

      // 4th and 5th are collapsed
      expect(find.text('Area Jakarta Timur'), findsNothing);
      expect(find.text('Area Depok'), findsNothing);

      // Verify +2 chip exists with Tooltip
      final moreChip = find.text('+2');
      expect(moreChip, findsOneWidget);

      final tooltipFinder = find.byType(Tooltip);
      expect(tooltipFinder, findsOneWidget);
      final Tooltip tooltip = tester.widget(tooltipFinder);
      expect(tooltip.message, contains('Area Jakarta Timur'));
      expect(tooltip.message, contains('Area Depok'));

      // Tap on +2 to trigger tooltip
      await tester.tap(moreChip);
      await tester.pump(const Duration(milliseconds: 500));

      // Tooltip text should now be visible on screen
      expect(find.textContaining('Area Jakarta Timur'), findsOneWidget);
    },
  );
}
