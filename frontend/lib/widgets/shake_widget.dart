import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Helper untuk membuat animasi getar (Shake Animation)
class ShakeAnimationHelper {
  static Animation<double> createShakeAnimation(
    AnimationController controller,
  ) {
    return TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut));
  }
}

/// Widget pembungkus untuk menerapkan efek getar ke widget anak
class ShakeWidget extends StatelessWidget {
  final Animation<double>? animation;
  final Widget child;

  const ShakeWidget({super.key, required this.animation, required this.child});

  @override
  Widget build(BuildContext context) {
    if (animation == null) {
      return child;
    }
    return AnimatedBuilder(
      animation: animation!,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(animation!.value, 0),
          child: child,
        );
      },
      child: child,
    );
  }
}

/// Formatter pembatas karakter yang memicu callback saat karakter melebihi batas
class LimitExceededFormatter extends TextInputFormatter {
  final int maxLength;
  final VoidCallback onExceeded;

  LimitExceededFormatter({required this.maxLength, required this.onExceeded});

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.length > maxLength) {
      onExceeded();
      if (oldValue.text.length <= maxLength) {
        return oldValue;
      }
      return TextEditingValue(
        text: newValue.text.substring(0, maxLength),
        selection: TextSelection.collapsed(offset: maxLength),
      );
    }
    return newValue;
  }
}
