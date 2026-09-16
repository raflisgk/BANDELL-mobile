import 'package:flutter/material.dart';

enum AppMessageType {
  error,
  success,
  warning,
  info,
}

class AppMessage extends StatelessWidget {
  final String message;
  final AppMessageType type;
  final VoidCallback? onClose;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;

  const AppMessage({
    super.key,
    required this.message,
    this.type = AppMessageType.error,
    this.onClose,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    Color backgroundColor;
    Color borderColor;
    Color textColor;
    IconData icon;
    Color iconColor;

    switch (type) {
      case AppMessageType.error:
        backgroundColor = const Color(0xFFFEF2F2);
        borderColor = const Color(0xFFFECACA);
        textColor = const Color(0xFF991B1B);
        icon = Icons.error_outline_rounded;
        iconColor = const Color(0xFFDC2626);
        break;
      case AppMessageType.success:
        backgroundColor = const Color(0xFFF0FDF4);
        borderColor = const Color(0xFFBBF7D0);
        textColor = const Color(0xFF166534);
        icon = Icons.check_circle_outline_rounded;
        iconColor = const Color(0xFF16A34A);
        break;
      case AppMessageType.warning:
        backgroundColor = const Color(0xFFFFFBEB);
        borderColor = const Color(0xFFFDE68A);
        textColor = const Color(0xFF92400E);
        icon = Icons.warning_amber_rounded;
        iconColor = const Color(0xFFD97706);
        break;
      case AppMessageType.info:
        backgroundColor = const Color(0xFFEFF6FF);
        borderColor = const Color(0xFFBFDBFE);
        textColor = const Color(0xFF1E40AF);
        icon = Icons.info_outline_rounded;
        iconColor = const Color(0xFF2563EB);
        break;
    }

    return Container(
      margin: margin ?? const EdgeInsets.only(bottom: 12.0),
      padding: padding ??
          const EdgeInsets.symmetric(
            horizontal: 14.0,
            vertical: 10.0,
          ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(
          color: borderColor,
          width: 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 1.5),
            child: Icon(
              icon,
              color: iconColor,
              size: 18,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.35,
              ),
            ),
          ),
          if (onClose != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onClose,
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Icon(
                  Icons.close_rounded,
                  size: 16,
                  color: textColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

