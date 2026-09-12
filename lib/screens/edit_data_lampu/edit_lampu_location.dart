import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EditLampuLocation extends StatelessWidget {
  final TextEditingController longitudeController;
  final TextEditingController latitudeController;
  final TextEditingController? alamatController;
  final FocusNode longitudeFocusNode;
  final FocusNode latitudeFocusNode;
  final FocusNode? alamatFocusNode;
  final bool isLoadingLocation;
  final VoidCallback? onGetLocation;

  const EditLampuLocation({
    super.key,
    required this.longitudeController,
    required this.latitudeController,
    this.alamatController,
    required this.longitudeFocusNode,
    required this.latitudeFocusNode,
    this.alamatFocusNode,
    this.isLoadingLocation = false,
    this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
        ),
        const SizedBox(height: 12),
        _buildCustomTextField(
          controller: longitudeController,
          focusNode: longitudeFocusNode,
          hint: '106.8456',
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
  }) {
    final isFocused = focusNode.hasFocus;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? AppColors.borderFocused : AppColors.border,
          width: isFocused ? 1.5 : 1.0,
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
