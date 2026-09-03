import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class PanelInputSection extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode? focusNode;

  const PanelInputSection({
    super.key,
    required this.controller,
    this.focusNode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Kode Panel / Titik',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Masukkan kode panel atau titik lokasi pemasangan',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
          ),
        ),

        const SizedBox(height: 14),

        // Input Field
        Container(
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isFocused ? AppColors.primary : AppColors.border,
              width: isFocused ? 1.5 : 1,
            ),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: const InputDecoration(
              hintText: 'Contoh: PNL-01',
              hintStyle: TextStyle(
                color: AppColors.hintColor,
                fontSize: 14,
              ),
              isDense: true,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }
}
