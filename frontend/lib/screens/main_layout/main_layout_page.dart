import 'package:flutter/material.dart';

import '../../services/main_navigation_service.dart';
import '../../widgets/bottom_navbar.dart';
import '../area_operasional/area_operasional_page.dart';
import '../history/history_page.dart';
import '../profile/profile_page.dart';

class MainLayoutPage extends StatefulWidget {
  final int initialIndex;

  const MainLayoutPage({super.key, this.initialIndex = 0});

  @override
  State<MainLayoutPage> createState() => _MainLayoutPageState();
}

class _MainLayoutPageState extends State<MainLayoutPage> {
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    MainNavigationService.hasMainLayout = true;
    if (widget.initialIndex >= 0 && widget.initialIndex <= 2) {
      MainNavigationService.setIndex(widget.initialIndex);
    }
    _pages = const [
      AreaOperasionalPage(isEmbedded: true),
      HistoryPage(isEmbedded: true),
      ProfilePage(isEmbedded: true),
    ];
  }

  @override
  void dispose() {
    MainNavigationService.hasMainLayout = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: MainNavigationService.currentTabNotifier,
      builder: (context, currentIndex, _) {
        final safeIndex = currentIndex.clamp(0, 2);
        return PopScope(
          canPop: safeIndex == 0,
          onPopInvokedWithResult: (didPop, _) {
            if (didPop) return;
            if (safeIndex != 0) {
              MainNavigationService.setIndex(0);
            }
          },
          child: Scaffold(
            extendBody: true,
            body: IndexedStack(
              index: safeIndex,
              children: _pages,
            ),
            bottomNavigationBar: BottomNavbar(
              currentIndex: safeIndex,
              onTap: (index) {
                MainNavigationService.setIndex(index);
              },
            ),
          ),
        );
      },
    );
  }
}

