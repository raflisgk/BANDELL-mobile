import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class LokasiCard extends StatelessWidget {
  final String? districtName;
  final String? latitude;
  final String? longitude;
  final String? coordinates;
  final String? address;

  const LokasiCard({
    super.key,
    this.districtName,
    this.latitude,
    this.longitude,
    this.coordinates,
    this.address,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveDistrict = (districtName != null &&
            districtName!.trim().isNotEmpty &&
            districtName!.trim() != '-')
        ? districtName!.trim()
        : '-';

    String effectiveCoords;
    final lat = latitude?.trim();
    final lng = longitude?.trim();
    if (lat != null &&
        lng != null &&
        lat.isNotEmpty &&
        lng.isNotEmpty &&
        lat != '-' &&
        lng != '-') {
      effectiveCoords = '$lat, $lng';
    } else if (coordinates != null &&
        coordinates!.trim().isNotEmpty &&
        coordinates!.trim() != '-') {
      effectiveCoords = coordinates!.trim();
    } else {
      effectiveCoords = '-';
    }

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.location_on_outlined,
              color: Color(0xFF94A3B8),
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  effectiveDistrict,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  effectiveCoords,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12.5,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
