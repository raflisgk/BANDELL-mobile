import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/screens/main_layout/main_layout_page.dart';
import 'package:mobile_teknisi/services/main_navigation_service.dart';

void main() {
  setUp(() {
    MainNavigationService.reset();
  });

  tearDown(() {
    MainNavigationService.reset();
  });

  group('MainNavigationService Tests', () {
    test('Initial index is 0', () {
      expect(MainNavigationService.currentIndex, equals(0));
    });

    test('setIndex updates currentIndex and notifies listeners', () {
      int? notifiedIndex;
      MainNavigationService.currentTabNotifier.addListener(() {
        notifiedIndex = MainNavigationService.currentIndex;
      });

      MainNavigationService.setIndex(1);
      expect(MainNavigationService.currentIndex, equals(1));
      expect(notifiedIndex, equals(1));

      MainNavigationService.switchToProfile();
      expect(MainNavigationService.currentIndex, equals(2));
      expect(notifiedIndex, equals(2));

      MainNavigationService.switchToProject();
      expect(MainNavigationService.currentIndex, equals(0));
      expect(notifiedIndex, equals(0));
    });
  });

  group('MainLayoutPage Widget Tests', () {
    testWidgets('Renders IndexedStack and BottomNavbar', (tester) async {
      await tester.pumpWidget(
        ScreenUtilInit(
          designSize: const Size(360, 800),
          minTextAdapt: true,
          builder: (context, child) => const MaterialApp(
            home: MainLayoutPage(),
          ),
        ),
      );

      await tester.pump();

      // Verify IndexedStack exists
      expect(find.byType(IndexedStack), findsOneWidget);
      final indexedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(indexedStack.index, equals(0));
      expect(indexedStack.children.length, equals(3));
      expect(MainNavigationService.hasMainLayout, isTrue);

      // Switch to History
      MainNavigationService.switchToHistory();
      await tester.pump();

      final updatedStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(updatedStack.index, equals(1));

      // Switch to Profile
      MainNavigationService.switchToProfile();
      await tester.pump();

      final profileStack = tester.widget<IndexedStack>(find.byType(IndexedStack));
      expect(profileStack.index, equals(2));
    });
  });
}

