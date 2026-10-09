import 'dart:io';

import 'package:flutter/material.dart';

import '../../services/api_service.dart';
import '../../utils/app_colors.dart';

class FotoDokumentasiCard extends StatelessWidget {
  final List<String>? photos;

  const FotoDokumentasiCard({super.key, this.photos});

  @override
  Widget build(BuildContext context) {
    final displayPhotos = (photos ?? [])
        .map((p) => ApiService.resolvePhotoUrl(p))
        .where((p) => p.isNotEmpty)
        .toList();

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
                  child: GestureDetector(
                    onTap: () => _showPhotoDialog(context, photoUrl),
                    child: _buildPhotoThumbnail(photoUrl),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildPhotoThumbnail(String url) {
    final resolvedUrl = ApiService.resolvePhotoUrl(url);
    final isNetwork =
        resolvedUrl.startsWith('http://') || resolvedUrl.startsWith('https://');

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.avatarCircleBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderMedium, width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(11),
        child: isNetwork
            ? Image.network(
                resolvedUrl,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                headers: const {'Connection': 'close'},
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Container(
                    color: AppColors.avatarCircleBackground,
                    child: const Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  debugPrint(
                    'Gagal memuat foto dokumentasi: $resolvedUrl, error: $error',
                  );
                  return _buildPlaceholder();
                },
              )
            : Image.file(
                File(resolvedUrl),
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildPlaceholder();
                },
              ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: AppColors.avatarCircleBackground,
      child: const Center(
        child: Icon(Icons.image_outlined, color: AppColors.primary, size: 26),
      ),
    );
  }

  void _showPhotoDialog(BuildContext context, String imageUrl) {
    final isNetwork =
        imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                color: AppColors.photoPreviewBackground,
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.75,
                ),
                child: isNetwork
                    ? Image.network(
                        imageUrl,
                        fit: BoxFit.contain,
                        headers: const {'Connection': 'close'},
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return const SizedBox(
                            height: 200,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: AppColors.backgroundWhite,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) =>
                            const SizedBox(
                              height: 200,
                              child: Center(
                                child: Icon(
                                  Icons.broken_image_rounded,
                                  color: AppColors.whiteAlpha70,
                                  size: 48,
                                ),
                              ),
                            ),
                      )
                    : Image.file(File(imageUrl), fit: BoxFit.contain),
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: AppColors.blackAlpha54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close_rounded,
                  color: AppColors.backgroundWhite,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
