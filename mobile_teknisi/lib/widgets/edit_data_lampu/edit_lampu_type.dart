import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EditLampuType extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final isFocused = tipeLampuFocusNode.hasFocus;

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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFocused ? AppColors.borderFocused : AppColors.border,
              width: isFocused ? 1.5 : 1.0,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: lampTypeOptions.contains(tipeLampuController.text)
                  ? tipeLampuController.text
                  : (lampTypeOptions.isNotEmpty ? lampTypeOptions.first : null),
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.textSecondary,
              ),
              isExpanded: true,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              onChanged: onChanged,
              items: lampTypeOptions
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
