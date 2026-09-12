import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class RealtimeLocationSection extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final FocusNode? latitudeFocusNode;
  final FocusNode? longitudeFocusNode;
  final bool isLoadingLocation;
  final VoidCallback onGetLocation;

  const RealtimeLocationSection({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.latitudeFocusNode,
    this.longitudeFocusNode,
    required this.isLoadingLocation,
    required this.onGetLocation,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLocation = latitudeController.text.isNotEmpty ||
        longitudeController.text.isNotEmpty;

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
              'Lokasi Koordinat',
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
          'Masukkan koordinat lampu (Lat/Long)',
          style: TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12.5,
          ),
        ),

        const SizedBox(height: 14),

        // STATE 2: Show Latitude & Longitude TextFields when location is filled
        if (hasLocation) ...[
          _buildInputField(
            controller: latitudeController,
            focusNode: latitudeFocusNode,
            hint: 'Latitude',
          ),
          const SizedBox(height: 10),
          _buildInputField(
            controller: longitudeController,
            focusNode: longitudeFocusNode,
            hint: 'Longitude',
          ),
        ] else ...[
          // STATE 1: Show Get Location Button (Green) when location is empty
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoadingLocation ? null : onGetLocation,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF15803D),
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    const Color(0xFF15803D).withValues(alpha: 0.7),
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
        readOnly: true,
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
