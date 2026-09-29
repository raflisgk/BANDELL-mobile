import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../utils/app_colors.dart';
import '../../widgets/shake_widget.dart';

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
  final EdgeInsetsGeometry? contentPadding;

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
    this.contentPadding,
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

    _shakeAnimation ??= ShakeAnimationHelper.createShakeAnimation(
      _shakeController!,
    );
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
    if (widget.focusNode != null &&
        !widget.focusNode!.hasFocus &&
        _isExceeded) {
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
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowLight,
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
            padding:
                widget.contentPadding ??
                const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
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
                    color: AppColors.primaryDark,
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
                          color: AppColors.whiteAlpha70,
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
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryDark, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowSoft,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShakeWidget(
            animation: _effectiveShakeAnimation,
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
                color: _isExceeded ? AppColors.error : AppColors.primaryDark,
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
                        LimitExceededFormatter(
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
                        color: AppColors.textSubtle,
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
                        : AppColors.primaryDark,
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
                    side: const BorderSide(color: AppColors.borderMedium),
                    backgroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: const Text(
                    'Batal',
                    style: TextStyle(
                      color: AppColors.textBody,
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
                    backgroundColor: AppColors.primaryDark,
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
