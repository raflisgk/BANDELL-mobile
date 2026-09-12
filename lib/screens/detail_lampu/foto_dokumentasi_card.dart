import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class FotoDokumentasiCard extends StatelessWidget {
  final List<String>? photos;
  final VoidCallback? onLihatSemua;

  const FotoDokumentasiCard({
    super.key,
    this.photos,
    this.onLihatSemua,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhotos = photos ?? [];

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${displayPhotos.length} FOTO DOKUMENTASI',
                style: const TextStyle(
                  color: AppColors.hintColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              if (onLihatSemua != null && displayPhotos.isNotEmpty)
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

          if (displayPhotos.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: const Center(
                child: Text(
                  'Belum ada foto dokumentasi',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            // 3 Photo Thumbnails Row
            Row(
              children: displayPhotos.take(3).map((photoUrl) {
                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: _buildPhotoThumbnail(photoUrl),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(String url) {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE2EBF8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFCBD5E1),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: Image.network(
          url,
          width: 72,
          height: 72,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: const Color(0xFFE2EBF8),
              child: const Center(
                child: Icon(
                  Icons.image_outlined,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
