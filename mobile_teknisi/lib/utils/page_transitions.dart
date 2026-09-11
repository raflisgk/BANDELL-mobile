import 'package:flutter/material.dart';

/// Instant / zero-duration route for instant tab switching
class InstantPageRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  InstantPageRoute({required this.page, super.settings})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: Duration.zero,
          reverseTransitionDuration: Duration.zero,
          transitionsBuilder: (context, animation, secondaryAnimation, child) => child,
        );
}

/// Kept for backward compatibility - now instant (zero delay)
class SmoothTabRoute<T> extends InstantPageRoute<T> {
  SmoothTabRoute({required super.page, super.settings});
}

/// Kept for backward compatibility - now instant (zero delay)
class SmoothSlideRoute<T> extends InstantPageRoute<T> {
  SmoothSlideRoute({required super.page, super.settings});
}

/// Fast, instant page transitions builder for theme-wide consistency (no slide, no fade, no zoom, no bounce)
class FastPageTransitionsBuilder extends PageTransitionsBuilder {
  const FastPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}

/// Backward compatibility alias
typedef SmoothPageTransitionsBuilder = FastPageTransitionsBuilder;

/// Navigation helpers for ultra-fast, responsive routing (sat-set like Instagram)
class AppNavigator {
  /// Tab switching (Bottom Navigation Bar): Instant transition (0ms)
  static Future<T?> pushTabReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      InstantPageRoute<T>(page: page),
    );
  }

  /// Push route with MaterialPageRoute (fast & responsive, no zoom/slide/fade delay)
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
    );
  }

  /// Push replacement with MaterialPageRoute
  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement<T, dynamic>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
    );
  }

  /// Push and remove all previous routes with MaterialPageRoute
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute<T>(
        builder: (_) => page,
      ),
      (route) => false,
    );
  }
}

