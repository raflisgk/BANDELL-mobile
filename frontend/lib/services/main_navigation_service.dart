import 'package:flutter/foundation.dart';

class MainNavigationService {
  static final ValueNotifier<int> currentTabNotifier = ValueNotifier<int>(0);
  static bool hasMainLayout = false;

  static int get currentIndex => currentTabNotifier.value;

  static void setIndex(int index) {
    if (currentTabNotifier.value != index) {
      currentTabNotifier.value = index;
    }
  }

  static void switchToProject() => setIndex(0);
  static void switchToHistory() => setIndex(1);
  static void switchToProfile() => setIndex(2);

  static void reset() {
    currentTabNotifier.value = 0;
    hasMainLayout = false;
  }
}
