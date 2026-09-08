import 'package:flutter/material.dart';

/// Smooth, fast fade transition route specifically for Bottom Navigation Bar tab switching
class SmoothTabRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothTabRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 250),
          reverseTransitionDuration: const Duration(milliseconds: 220),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeOut,
                reverseCurve: Curves.easeIn,
              ),
              child: child,
            );
          },
        );
}

/// Smooth slide & fade transition route for pushing sub-pages / detail screens
class SmoothSlideRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothSlideRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 280),
          reverseTransitionDuration: const Duration(milliseconds: 250),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.05, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
                reverseCurve: Curves.easeInCubic,
              ),
            );

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
              reverseCurve: Curves.easeIn,
            );

            return SlideTransition(
              position: slideAnimation,
              child: FadeTransition(
                opacity: fadeAnimation,
                child: child,
              ),
            );
          },
        );
}

/// Smooth, lightweight page transitions builder for theme-wide consistency
class SmoothPageTransitionsBuilder extends PageTransitionsBuilder {
  const SmoothPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final slideAnimation = Tween<Offset>(
      begin: const Offset(0.05, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    final fadeAnimation = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    return SlideTransition(
      position: slideAnimation,
      child: FadeTransition(
        opacity: fadeAnimation,
        child: child,
      ),
    );
  }
}

/// Navigation helpers for quick, smooth routing
class AppNavigator {
  /// Push replacement with smooth fade transition (perfect for bottom navbar tabs)
  static Future<T?> pushTabReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      SmoothTabRoute<T>(page: page),
    );
  }

  /// Push route with smooth slide & fade transition (perfect for detail pages)
  static Future<T?> push<T>(BuildContext context, Widget page) {
    return Navigator.push(
      context,
      SmoothSlideRoute<T>(page: page),
    );
  }

  /// Push replacement with smooth slide & fade transition
  static Future<T?> pushReplacement<T>(BuildContext context, Widget page) {
    return Navigator.pushReplacement(
      context,
      SmoothSlideRoute<T>(page: page),
    );
  }

  /// Push and remove all previous routes with smooth transition
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil(
      context,
      SmoothSlideRoute<T>(page: page),
      (route) => false,
    );
  }
}

