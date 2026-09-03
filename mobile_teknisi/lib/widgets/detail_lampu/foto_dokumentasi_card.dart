import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class FotoDokumentasiCard extends StatelessWidget {
  final VoidCallback? onLihatSemua;

  const FotoDokumentasiCard({
    super.key,
    this.onLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '3 FOTO DOKUMENTASI',
                style: TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (onLihatSemua != null)
                GestureDetector(
                  onTap: onLihatSemua,
                  child: const Text(
                    'Lihat Semua',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),

          // 3 Thumbnail Placeholders
          Row(
            children: [
              _buildPhotoThumbnail(
                icon: Icons.streetview_rounded,
                label: 'Foto 1',
              ),
              const SizedBox(width: 10),
              _buildPhotoThumbnail(
                icon: Icons.camera_alt_rounded,
                label: 'Foto 2',
              ),
              const SizedBox(width: 10),
              _buildPhotoThumbnail(
                icon: Icons.lightbulb_rounded,
                label: 'Foto 3',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail({
    required IconData icon,
    required String label,
  }) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.searchBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.border,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 26,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
