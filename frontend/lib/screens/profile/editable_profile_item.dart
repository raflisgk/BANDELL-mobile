import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../utils/app_colors.dart';

class EditableProfileItem extends StatefulWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isEditing;
  final bool isEditable;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final TextInputType keyboardType;
  final int? maxLength;
  final List<TextInputFormatter>? inputFormatters;
  final VoidCallback? onTap;
  final VoidCallback? onSave;
  final VoidCallback? onCancel;

  const EditableProfileItem({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    this.isEditing = false,
    this.isEditable = true,
    this.controller,
    this.focusNode,
    this.keyboardType = TextInputType.text,
    this.maxLength,
    this.inputFormatters,
    this.onTap,
    this.onSave,
    this.onCancel,
  });

  @override
  State<EditableProfileItem> createState() => _EditableProfileItemState();
}

class _EditableProfileItemState extends State<EditableProfileItem>
    with SingleTickerProviderStateMixin {
  AnimationController? _shakeController;
  Animation<double>? _shakeAnimation;
  bool _isExceeded = false;
  Timer? _errorTimer;

  void _initShakeAnimation() {
    _shakeController ??= AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _shakeAnimation ??= TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -6.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -6.0, end: 6.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 6.0, end: -4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -4.0, end: 4.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 4.0, end: -2.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -2.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(
      parent: _shakeController!,
      curve: Curves.easeInOut,
    ));
  }

  AnimationController get _effectiveShakeController {
    if (_shakeController == null) _initShakeAnimation();
    return _shakeController!;
  }

  Animation<double> get _effectiveShakeAnimation {
    if (_shakeAnimation == null) _initShakeAnimation();
    return _shakeAnimation!;
  }

  @override
  void initState() {
    super.initState();
    _initShakeAnimation();
    widget.controller?.addListener(_onTextChanged);
    widget.focusNode?.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(EditableProfileItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
    }
    if (oldWidget.focusNode != widget.focusNode) {
      oldWidget.focusNode?.removeListener(_onFocusChanged);
      widget.focusNode?.addListener(_onFocusChanged);
    }
    if (!widget.isEditing && _isExceeded) {
      _errorTimer?.cancel();
      _isExceeded = false;
    }
  }

  @override
  void dispose() {
    _errorTimer?.cancel();
    _shakeController?.dispose();
    widget.controller?.removeListener(_onTextChanged);
    widget.focusNode?.removeListener(_onFocusChanged);
    super.dispose();
  }

  void _onTextChanged() {
    if (_isExceeded && widget.controller != null && widget.maxLength != null) {
      if (widget.controller!.text.length < widget.maxLength!) {
        _errorTimer?.cancel();
        setState(() {
          _isExceeded = false;
        });
      }
    }
  }

  void _onFocusChanged() {
    if (widget.focusNode != null && !widget.focusNode!.hasFocus && _isExceeded) {
      _errorTimer?.cancel();
      setState(() {
        _isExceeded = false;
      });
    }
  }

  void _onLimitExceeded() {
    _errorTimer?.cancel();
    if (!_isExceeded) {
      setState(() {
        _isExceeded = true;
      });
    }
    _effectiveShakeController.forward(from: 0.0);

    _errorTimer = Timer(const Duration(milliseconds: 1500), () {
      if (mounted && _isExceeded) {
        setState(() {
          _isExceeded = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isEditing) {
      return _buildEditMode();
    }
    return _buildNormalMode();
  }

  Widget _buildNormalMode() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF084B83),
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: widget.isEditable ? widget.onTap : null,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                // White Rounded Container for Icon
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    widget.icon,
                    color: const Color(0xFF084B83),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Title & Value Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.value,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Chevron Icon only shown if field is editable
                if (widget.isEditable)
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEditMode() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF084B83),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0F000000),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedBuilder(
            animation: _effectiveShakeAnimation,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_effectiveShakeAnimation.value, 0),
                child: child,
              );
            },
            child: Text(
              widget.title,
              style: TextStyle(
                color: _isExceeded ? AppColors.error : AppColors.textPrimary,
                fontSize: 13.5,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // TextField Container with Pencil Icon on Right
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: _isExceeded
                    ? AppColors.error
                    : const Color(0xFF084B83),
                width: _isExceeded ? 1.5 : 1.2,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    focusNode: widget.focusNode,
                    keyboardType: widget.keyboardType,
                    inputFormatters: [
                      if (widget.maxLength != null)
                        _ProfileItemLimitFormatter(
                          maxLength: widget.maxLength!,
                          onExceeded: _onLimitExceeded,
                        )
                      else if (widget.inputFormatters != null)
                        ...widget.inputFormatters!,
                    ],
                    style: TextStyle(
                      color: _isExceeded
                          ? AppColors.error
                          : AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w600,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Masukkan ${widget.title}',
                      hintStyle: const TextStyle(
                        color: Color(0xFF94A3B8),
                        fontSize: 13.5,
                      ),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Icon(
                    Icons.edit_outlined,
                    color: _isExceeded
                        ? AppColors.error
                        : const Color(0xFF084B83),
                    size: 18,
                  ),
                ),
              ],
            ),
          ),

          if (_isExceeded && widget.maxLength != null) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 2.0),
              child: Text(
                'Maksimal ${widget.maxLength} karakter',
                style: const TextStyle(
                  color: AppColors.error,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 10),

          // Action Buttons: Batal & Simpan
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: widget.onCancel,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 13.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: widget.onSave,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF084B83),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Colors.white,
                  ),
                  label: const Text(
                    'Simpan',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileItemLimitFormatter extends TextInputFormatter {
  final int maxLength;
  final VoidCallback onExceeded;

  _ProfileItemLimitFormatter({
    required this.maxLength,
    required this.onExceeded,
  });

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

