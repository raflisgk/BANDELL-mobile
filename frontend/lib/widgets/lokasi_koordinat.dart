import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_colors.dart';
import '../utils/validators.dart';
import 'shake_widget.dart';

/// Reusable Widget Lokasi Koordinat (Latitude & Longitude)
/// Mendukung mode Manual (ketik langsung), Realtime (GPS otomatis), dan Edit Lampu.
class LokasiKoordinat extends StatelessWidget {
  final TextEditingController latitudeController;
  final TextEditingController longitudeController;
  final FocusNode? latitudeFocusNode;
  final FocusNode? longitudeFocusNode;
  final bool isGpsMode;
  final bool isLoadingGps;
  final VoidCallback? onGetGpsLocation;
  final String? errorMessage;
  final bool readOnly;
  final bool isRequired;
  final String title;
  final String subtitle;
  final IconData icon;
  final Animation<double>? shakeAnimation;
  final bool isLatitudeExceeded;
  final bool isLongitudeExceeded;
  final VoidCallback? onLatitudeLimitExceeded;
  final VoidCallback? onLongitudeLimitExceeded;
  final String latitudeHint;
  final String longitudeHint;

  const LokasiKoordinat({
    super.key,
    required this.latitudeController,
    required this.longitudeController,
    this.latitudeFocusNode,
    this.longitudeFocusNode,
    this.isGpsMode = false,
    this.isLoadingGps = false,
    this.onGetGpsLocation,
    this.errorMessage,
    this.readOnly = false,
    this.isRequired = true,
    this.title = 'Lokasi Koordinat',
    this.subtitle = 'Masukkan koordinat lampu (Lat/Long)',
    this.icon = Icons.location_on_outlined,
    this.shakeAnimation,
    this.isLatitudeExceeded = false,
    this.isLongitudeExceeded = false,
    this.onLatitudeLimitExceeded,
    this.onLongitudeLimitExceeded,
    this.latitudeHint = 'Latitude',
    this.longitudeHint = 'Longitude',
  });

  @override
  Widget build(BuildContext context) {
    final bool hasLocation =
        latitudeController.text.isNotEmpty ||
        longitudeController.text.isNotEmpty;

    final bool isHeaderError = isLatitudeExceeded || isLongitudeExceeded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8.0, left: 2.0),
            child: Text(
              errorMessage!,
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.1,
              ),
            ),
          ),

        // Section Header
        ShakeWidget(
          animation: shakeAnimation,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isHeaderError
                      ? AppColors.errorLight
                      : AppColors.primaryLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isHeaderError ? AppColors.error : AppColors.primary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (isRequired) ...[
                const SizedBox(width: 4),
                const Text(
                  '*',
                  style: TextStyle(
                    color: AppColors.error,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),

        const SizedBox(height: 14),

        // Body: GPS Button (if GPS mode and empty) OR Coordinate Inputs
        if (isGpsMode && !hasLocation)
          _buildGpsButton()
        else ...[
          _buildCoordinateField(
            controller: latitudeController,
            focusNode: latitudeFocusNode,
            hint: latitudeHint,
            maxLength: 10,
            isExceeded: isLatitudeExceeded,
            onExceeded: onLatitudeLimitExceeded,
            hasError:
                errorMessage != null &&
                !Validators.isLatitudeValid(latitudeController.text),
          ),
          const SizedBox(height: 10),
          _buildCoordinateField(
            controller: longitudeController,
            focusNode: longitudeFocusNode,
            hint: longitudeHint,
            maxLength: 11,
            isExceeded: isLongitudeExceeded,
            onExceeded: onLongitudeLimitExceeded,
            hasError:
                errorMessage != null &&
                !Validators.isLongitudeValid(longitudeController.text),
          ),
        ],
      ],
    );
  }

  Widget _buildGpsButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoadingGps ? null : onGetGpsLocation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.statusTerverifikasiText,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppColors.statusTerverifikasiText.withValues(
            alpha: 0.7,
          ),
          elevation: 0,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        child: isLoadingGps
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
    );
  }

  Widget _buildCoordinateField({
    required TextEditingController controller,
    FocusNode? focusNode,
    required String hint,
    required int maxLength,
    bool isExceeded = false,
    VoidCallback? onExceeded,
    bool hasError = false,
  }) {
    final bool isFocused = focusNode?.hasFocus ?? false;

    final borderColor = isExceeded
        ? AppColors.error
        : (hasError
              ? AppColors.error
              : (isFocused ? AppColors.primary : AppColors.border));
    final borderWidth = (isExceeded || hasError || isFocused) ? 1.5 : 1.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            color: isFocused ? Colors.white : AppColors.inputBackground,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: borderColor, width: borderWidth),
          ),
          child: TextField(
            controller: controller,
            focusNode: focusNode,
            readOnly: readOnly,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
              signed: true,
            ),
            inputFormatters: [
              if (onExceeded != null)
                LimitExceededFormatter(
                  maxLength: maxLength,
                  onExceeded: onExceeded,
                )
              else
                LengthLimitingTextInputFormatter(maxLength),
            ],
            style: TextStyle(
              color: isExceeded ? AppColors.error : AppColors.textPrimary,
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
        ),
        if (isExceeded) ...[
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 2.0),
            child: Text(
              'Maksimal $maxLength karakter',
              style: const TextStyle(
                color: AppColors.error,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
