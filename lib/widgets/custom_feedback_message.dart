import 'dart:async';
import 'package:flutter/material.dart';

enum FeedbackType {
  error,
  success,
}

class CustomFeedbackMessage {
  static OverlayEntry? _currentEntry;
  static Timer? _dismissTimer;

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

  static void showError(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.error);
  }

  static void showSuccess(BuildContext context, String message) {
    show(context, message: message, type: FeedbackType.success);
  }

  static void hide() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _currentEntry?.remove();
    _currentEntry = null;
  }
}

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
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, -0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      ),
    );

    _controller.forward();

    _timer = Timer(widget.duration, _handleAutoDismiss);
  }

  void _handleAutoDismiss() {
    if (!mounted) return;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismiss();
      }
    });
  }

  void _handleTapDismiss() {
    _timer?.cancel();
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
    final bool isError = widget.type == FeedbackType.error;

    final Color backgroundColor =
        isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4);
    final Color borderColor =
        isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0);
    final Color textColor =
        isError ? const Color(0xFF991B1B) : const Color(0xFF166534);
    final Color iconColor =
        isError ? const Color(0xFFDC2626) : const Color(0xFF16A34A);
    final IconData icon = isError
        ? Icons.error_outline_rounded
        : Icons.check_circle_outline_rounded;

    return SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: const EdgeInsets.only(top: 14.0, left: 20.0, right: 20.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Material(
                color: Colors.transparent,
                child: GestureDetector(
                  onTap: _handleTapDismiss,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 420),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14.0,
                      vertical: 10.0,
                    ),
                    decoration: BoxDecoration(
                      color: backgroundColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: borderColor,
                        width: 1.0,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          icon,
                          color: iconColor,
                          size: 18,
                        ),
                        const SizedBox(width: 9),
                        Flexible(
                          child: Text(
                            widget.message,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              height: 1.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

