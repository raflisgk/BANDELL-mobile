import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EditLampuType extends StatefulWidget {
  final TextEditingController tipeLampuController;
  final FocusNode tipeLampuFocusNode;
  final List<String> lampTypeOptions;
  final ValueChanged<String?> onChanged;

  const EditLampuType({
    super.key,
    required this.tipeLampuController,
    required this.tipeLampuFocusNode,
    required this.lampTypeOptions,
    required this.onChanged,
  });

  @override
  State<EditLampuType> createState() => _EditLampuTypeState();
}

class _EditLampuTypeState extends State<EditLampuType> {
  final GlobalKey _fieldKey = GlobalKey();
  bool _isOpen = false;

  void _openDropdownMenu(BuildContext context) async {
    final cleanOptions = widget.lampTypeOptions
        .where((opt) => opt.trim().isNotEmpty && opt.trim() != '-')
        .toList();

    if (cleanOptions.isEmpty) return;

    final RenderBox? box =
        _fieldKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final Offset position = box.localToGlobal(Offset.zero);
    final Size size = box.size;
    final RenderBox overlayBox =
        Overlay.of(context).context.findRenderObject() as RenderBox;

    setState(() => _isOpen = true);

    final selected = await showMenu<String>(
      context: context,
      position: RelativeRect.fromLTRB(
        position.dx,
        position.dy + size.height + 6,
        overlayBox.size.width - (position.dx + size.width),
        0,
      ),
      constraints: BoxConstraints(
        minWidth: size.width,
        maxWidth: size.width,
        maxHeight: 230,
      ),
      color: Colors.white,
      elevation: 6,
      shadowColor: AppColors.shadowMedium,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border, width: 1),
      ),
      items: cleanOptions.map((String item) {
        final bool isSelected =
            item.trim().toLowerCase() ==
            widget.tipeLampuController.text.trim().toLowerCase();

        return PopupMenuItem<String>(
          value: item,
          height: 44,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryLight : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    item,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textPrimary,
                      fontSize: 13.5,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(
                    Icons.check_rounded,
                    color: AppColors.primary,
                    size: 18,
                  ),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );

    if (mounted) {
      setState(() => _isOpen = false);
    }

    if (selected != null) {
      widget.tipeLampuController.text = selected;
      widget.onChanged(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isFocused = widget.tipeLampuFocusNode.hasFocus;
    final currentText = widget.tipeLampuController.text.trim();
    final displayText = currentText.isNotEmpty && currentText != '-'
        ? currentText
        : (widget.lampTypeOptions.isNotEmpty
            ? widget.lampTypeOptions.first
            : 'Pilih Tipe Lampu');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.lightbulb_outline_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Tipe Lampu',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Pilih tipe / jenis lampu',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          key: _fieldKey,
          onTap: () => _openDropdownMenu(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _isOpen || isFocused
                    ? AppColors.borderFocused
                    : AppColors.border,
                width: _isOpen || isFocused ? 1.5 : 1.0,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    displayText,
                    style: TextStyle(
                      color: currentText.isNotEmpty && currentText != '-'
                          ? AppColors.textPrimary
                          : AppColors.hintColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                AnimatedRotation(
                  turns: _isOpen ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
