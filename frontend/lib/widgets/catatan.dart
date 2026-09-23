import 'package:flutter/material.dart';

/// Reusable Widget Catatan (Opsional)
/// Sesuai dengan desain form teknisi (berpasangan dengan KodePanel & Dokumentasi)
class Catatan extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? title;
  final String? subtitle;
  final bool isOptional;
  final String? hintText;
  final int minLines;
  final int maxLines;

  const Catatan({
    super.key,
    required this.controller,
    this.focusNode,
    this.title,
    this.subtitle,
    this.isOptional = true,
    this.hintText = '-',
    this.minLines = 1,
    this.maxLines = 3,
  });

  @override
  State<Catatan> createState() => _CatatanState();
}

class _CatatanState extends State<Catatan> {
  late FocusNode _effectiveFocusNode;
  bool _isInternalFocusNode = false;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _effectiveFocusNode = FocusNode();
      _isInternalFocusNode = true;
    } else {
      _effectiveFocusNode = widget.focusNode!;
    }
    _effectiveFocusNode.addListener(_handleFocusChange);
  }

  void _handleFocusChange() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void didUpdateWidget(Catatan oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.focusNode != oldWidget.focusNode) {
      oldWidget.focusNode?.removeListener(_handleFocusChange);
      if (widget.focusNode == null) {
        _effectiveFocusNode = FocusNode();
        _isInternalFocusNode = true;
      } else {
        if (_isInternalFocusNode) {
          _effectiveFocusNode.dispose();
          _isInternalFocusNode = false;
        }
        _effectiveFocusNode = widget.focusNode!;
      }
      _effectiveFocusNode.addListener(_handleFocusChange);
    }
  }

  @override
  void dispose() {
    _effectiveFocusNode.removeListener(_handleFocusChange);
    if (_isInternalFocusNode) {
      _effectiveFocusNode.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isFocused = _effectiveFocusNode.hasFocus;
    final String displayTitle = widget.title ?? 'Catatan';
    final String displaySubtitle = widget.subtitle ?? 'Masukkan catatan';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF), // Soft light blue
                borderRadius: BorderRadius.circular(9),
              ),
              child: const Icon(
                Icons.content_paste_outlined,
                color: Color(0xFF2563EB), // Primary blue
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        displayTitle,
                        style: const TextStyle(
                          color: Color(0xFF1E293B),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.isOptional) ...[
                        const SizedBox(width: 4),
                        const Text(
                          '(Opsional)',
                          style: TextStyle(
                            color: Color(0xFF94A3B8),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    displaySubtitle,
                    style: const TextStyle(
                      color: Color(0xFF94A3B8),
                      fontSize: 12.5,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        // Multiline Input Field
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
              width: isFocused ? 1.5 : 1.0,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            focusNode: _effectiveFocusNode,
            minLines: widget.minLines,
            maxLines: widget.maxLines,
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: const TextStyle(
                color: Color(0xFF94A3B8),
                fontSize: 14,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 10,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}

