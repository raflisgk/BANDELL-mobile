import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class LocationGpsSection extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final FocusNode? latitudeFocusNode;
  final FocusNode? longitudeFocusNode;
  final bool isLoadingLocation;
  final VoidCallback? onGetLocation;
  final bool showGetLocationButton;
  final bool isReadOnly;

  const LocationGpsSection({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.latitudeFocusNode,
    this.longitudeFocusNode,
    this.isLoadingLocation = false,
    this.onGetLocation,
    this.showGetLocationButton = true,
    this.isReadOnly = false,
  });

  @override
  Widget build(BuildContext context) {
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
                Icons.location_on_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Lokasi (GPS)',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        const Text(
          'Ambil koordinat posisi saat ini',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
          ),
        ),

        const SizedBox(height: 14),

        // Latitude TextField
        _buildInputField(
          controller: latitudeController,
          focusNode: latitudeFocusNode,
          hint: 'Latitude',
          readOnly: isReadOnly,
        ),

        const SizedBox(height: 10),

        // Longitude TextField
        _buildInputField(
          controller: longitudeController,
          focusNode: longitudeFocusNode,
          hint: 'Longitude',
          readOnly: isReadOnly,
        ),

        if (showGetLocationButton && onGetLocation != null) ...[
          const SizedBox(height: 12),

          // Get Location Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingLocation ? null : onGetLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF15803D).withValues(alpha: 0.7),
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: isLoadingLocation
                  ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Mengambil lokasi...',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 18,
                              color: Colors.white,
                            ),
                            SizedBox(width: 6),
                            Text(
                              'Get Location',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Ambil koordinat otomatis dari GPS',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white70,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required bool readOnly,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    return Container(
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
        readOnly: readOnly,
        keyboardType: const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        ),
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(
            color: AppColors.hintColor,
            fontSize: 14,
          ),
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 12,
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }
}
