import 'dart:async';
import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

enum FeedbackType {
  success,
  error,
}

/// Global Reusable Feedback Widget & Overlay Manager for BANDELL Mobile
class CustomFeedback extends StatelessWidget {
  final FeedbackType type;
  final String message;
  final VoidCallback? onDismiss;

  const CustomFeedback({
    super.key,
    required this.type,
    required this.message,
    this.onDismiss,
  });

  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

  /// Show floating notification overlay at the top of the screen
  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.error,
    Duration duration = const Duration(milliseconds: 2700),
  }) {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (context) => _FloatingFeedbackOverlay(
        message: message,
        type: type,
        duration: duration,
        onDismiss: () {
          if (_currentEntry == entry) {
            _currentEntry?.remove();
            _currentEntry = null;
            _dismissTimer?.cancel();
            _dismissTimer = null;
          }
        },
      ),
    );

    _currentEntry = entry;
    overlay.insert(entry);
  }

  /// Shortcut to show success floating notification
  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.success);
  }

  /// Shortcut to show error floating notification
  static void showError(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.error);
  }

  /// Hide any currently active floating notification
  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }

  @override
  Widget build(BuildContext context) {
    final bool isSuccess = type == FeedbackType.success;

    final Color bgColor =
        isSuccess ? AppColors.realtimeBackground : const Color(0xFFFEF2F2);
    final Color borderColor =
        isSuccess ? AppColors.realtimeBorder : const Color(0xFFFECACA);
    final Color iconColor =
        isSuccess ? AppColors.realtimeGreen : AppColors.error;
    final Color textColor =
        isSuccess ? const Color(0xFF166534) : const Color(0xFF991B1B);
    final IconData iconData =
        isSuccess ? Icons.check_circle_rounded : Icons.error_outline_rounded;

    return Material(
      color: Colors.transparent,
      child: GestureDetector(
        onTap: onDismiss,
        child: Container(
          constraints: const BoxConstraints(maxWidth: 400),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: borderColor, width: 1),
            boxShadow: const [
              BoxShadow(
                color: Color(0x14000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                iconData,
                color: iconColor,
                size: 20,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  message,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.1,
                    height: 1.3,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Backward compatibility alias
typedef CustomFeedbackMessage = CustomFeedback;

class _FloatingFeedbackOverlay extends StatefulWidget {
  final String message;
  final FeedbackType type;
  final Duration duration;
  final VoidCallback onDismiss;

  const _FloatingFeedbackOverlay({
    required this.message,
    required this.type,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_FloatingFeedbackOverlay> createState() =>
      _FloatingFeedbackOverlayState();
}

class _FloatingFeedbackOverlayState extends State<_FloatingFeedbackOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
      reverseDuration: const Duration(milliseconds: 220),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.4),
      end: Offset.zero,
    ).animate(_fadeAnimation);

    _controller.forward();

    _timer = Timer(widget.duration, () {
      _dismissWithAnimation();
    });
  }

  void _dismissWithAnimation() {
    if (!mounted) return;
    _timer?.cancel();
    _timer = null;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 10;

    return Positioned(
      top: topPadding,
      left: 20,
      right: 20,
      child: Center(
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CustomFeedback(
              type: widget.type,
              message: widget.message,
              onDismiss: _dismissWithAnimation,
            ),
          ),
        ),
      ),
    );
  }
}

