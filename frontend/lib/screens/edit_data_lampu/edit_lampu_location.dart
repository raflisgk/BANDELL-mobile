import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EditLampuLocation extends StatelessWidget {
  final TextEditingController longitudeController;
  final TextEditingController latitudeController;
  final FocusNode longitudeFocusNode;
  final FocusNode latitudeFocusNode;
  final String? errorMessage;

  const EditLampuLocation({
    super.key,
    required this.longitudeController,
    required this.latitudeController,
    required this.longitudeFocusNode,
    required this.latitudeFocusNode,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),
        // 1. LOKASI KOORDINAT
        _buildSectionHeader(
          icon: Icons.language_rounded,
          title: 'Lokasi Koordinat',
          subtitle: 'Masukkan koordinat lampu (Long/Lat)',
        ),
        const SizedBox(height: 12),
        _buildCustomTextField(
          controller: latitudeController,
          focusNode: latitudeFocusNode,
          hint: '-6.2088',
          hasError: errorMessage != null,
        ),
        const SizedBox(height: 12),
        _buildCustomTextField(
          controller: longitudeController,
          focusNode: longitudeFocusNode,
          hint: '106.8456',
          hasError: errorMessage != null,
        ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.primary,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required FocusNode focusNode,
    required String hint,
    IconData? prefixIcon,
    bool hasError = false,
  }) {
    final isFocused = focusNode.hasFocus;

    final borderColor = hasError
        ? const Color(0xFFEF4444)
        : (isFocused ? AppColors.borderFocused : AppColors.border);
    final borderWidth = (hasError || isFocused) ? 1.5 : 1.0;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 14,
          ),
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: AppColors.iconColor,
                  size: 20,
                )
              : null,
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
