import 'package:flutter/material.dart';
import '../../utils/app_colors.dart';

class EditLampuDocumentation extends StatelessWidget {
  final List<String>? photos;
  final VoidCallback onTambahFoto;

  static const List<String> defaultPhotos = [
    'https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=300&q=80',
    'https://images.unsplash.com/photo-1477959858617-67f30bc75b82?w=300&q=80',
    'https://images.unsplash.com/photo-1519501025264-65ba15a82390?w=300&q=80',
  ];

  const EditLampuDocumentation({
    super.key,
    this.photos,
    required this.onTambahFoto,
  });

  @override
  Widget build(BuildContext context) {
    final displayPhotos = (photos != null && photos!.isNotEmpty)
        ? photos!
        : defaultPhotos;

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
                Icons.camera_alt_outlined,
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
                    'Dokumentasi',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    'Tambahkan foto kondisi lampu (maks. 5 foto)',
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

        // 3 Photo Thumbnails Row
        Row(
          children: displayPhotos.take(3).map((photoUrl) {
            return Padding(
              padding: const EdgeInsets.only(right: 10),
              child: _buildPhotoThumbnail(photoUrl),
            );
          }).toList(),
        ),

        const SizedBox(height: 12),

        // Tambah Foto Button Box
        GestureDetector(
          onTap: onTambahFoto,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF93C5FD),
                width: 1.2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(
                  Icons.add_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
                SizedBox(height: 2),
                Text(
                  'Tambah Foto',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontSize: 9.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
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
