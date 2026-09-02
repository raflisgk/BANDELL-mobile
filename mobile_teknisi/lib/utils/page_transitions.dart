import 'package:flutter/material.dart';

/// Smooth, fast fade transition route specifically for Bottom Navigation Bar tab switching
class SmoothTabRoute<T> extends PageRouteBuilder<T> {
  final Widget page;

  SmoothTabRoute({required this.page})
      : super(
          pageBuilder: (context, animation, secondaryAnimation) => page,
          transitionDuration: const Duration(milliseconds: 150),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
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
          transitionDuration: const Duration(milliseconds: 220),
          reverseTransitionDuration: const Duration(milliseconds: 200),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final slideAnimation = Tween<Offset>(
              begin: const Offset(0.06, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ),
            );

            final fadeAnimation = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOut,
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

  /// Push and remove all previous routes with smooth transition
  static Future<T?> pushAndRemoveUntil<T>(BuildContext context, Widget page) {
    return Navigator.pushAndRemoveUntil(
      context,
      SmoothSlideRoute<T>(page: page),
      (route) => false,
    );
  }
}
