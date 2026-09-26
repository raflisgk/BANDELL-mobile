import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';
import '../utils/app_colors.dart';
import 'custom_feedback.dart';

class Dokumentasi extends StatelessWidget {
  final List<String> photos;
  final VoidCallback? onAddPhoto;
  final ValueChanged<String>? onPhotoAdded;
  final Function(int index) onRemovePhoto;
  final int maxPhotos;

  const Dokumentasi({
    super.key,
    required this.photos,
    this.onAddPhoto,
    this.onPhotoAdded,
    required this.onRemovePhoto,
    this.maxPhotos = 4,
  });

  /// Helper statis untuk menampilkan bottom sheet pemilihan sumber foto (Galeri / Kamera)
  static Future<void> showPhotoPicker({
    required BuildContext context,
    required ValueChanged<String> onImagePicked,
  }) async {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderMedium,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Tambah Foto Dokumentasi',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.photo_library_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Pilih dari Galeri',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Buka galeri hp untuk memilih foto'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    pickImage(
                      context: context,
                      source: ImageSource.gallery,
                      onImagePicked: onImagePicked,
                    );
                  },
                ),
                const Divider(height: 1),
                ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  title: const Text(
                    'Ambil Foto Kamera',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text('Buka kamera untuk mengambil foto baru'),
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    pickImage(
                      context: context,
                      source: ImageSource.camera,
                      onImagePicked: onImagePicked,
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Helper statis untuk memanggil ImagePicker
  static Future<void> pickImage({
    required BuildContext context,
    required ImageSource source,
    required ValueChanged<String> onImagePicked,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
      );

      if (image != null) {
        onImagePicked(image.path);
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
      if (context.mounted) {
        CustomFeedbackMessage.showError(context, 'Gagal mengambil foto.');
      }
    }
  }

  void _handleTapAdd(BuildContext context) {
    if (onAddPhoto != null) {
      onAddPhoto!();
    } else if (onPhotoAdded != null) {
      if (photos.length >= maxPhotos) {
        CustomFeedbackMessage.showError(
          context,
          'Maksimal $maxPhotos foto sudah tercapai.',
        );
        return;
      }
      showPhotoPicker(context: context, onImagePicked: onPhotoAdded!);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header: Icon Kamera, Title, (Opsional), Subtitle
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.primary,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Row(
                children: const [
                  Flexible(
                    child: Text(
                      'Dokumentasi',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 6),
                  Text(
                    '(Opsional)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tambahkan foto kondisi lampu (maks. $maxPhotos foto)',
          style: const TextStyle(color: AppColors.textMuted, fontSize: 12.5),
        ),

        const SizedBox(height: 14),

        // Photo Thumbnails & Add Photo Button Row
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          physics: const ClampingScrollPhysics(),
          child: Row(
            children: [
              // Render Added Photo Thumbnails
              ...List.generate(photos.length, (index) {
                final rawPhotoItem = photos[index];
                final resolvedPhoto = ApiService.resolvePhotoUrl(rawPhotoItem);
                final bool isNetwork =
                    resolvedPhoto.startsWith('http://') ||
                    resolvedPhoto.startsWith('https://');

                return Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        width: 84,
                        height: 84,
                        decoration: BoxDecoration(
                          color: AppColors.avatarCircleBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderMedium,
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(11),
                          child: isNetwork
                              ? Image.network(
                                  resolvedPhoto,
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return const Center(
                                          child: SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        );
                                      },
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildErrorThumbnail();
                                  },
                                )
                              : Image.file(
                                  File(resolvedPhoto),
                                  width: 84,
                                  height: 84,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return _buildErrorThumbnail();
                                  },
                                ),
                        ),
                      ),
                      Positioned(
                        top: -4,
                        right: -4,
                        child: GestureDetector(
                          onTap: () => onRemovePhoto(index),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 13,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // Add Photo Box (Only if less than maxPhotos)
              if (photos.length < maxPhotos)
                GestureDetector(
                  onTap: () => _handleTapAdd(context),
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: BoxDecoration(
                      color: AppColors.inputBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.4),
                        width: 1.2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.add_rounded,
                          color: AppColors.primary,
                          size: 26,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Tambah Foto',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorThumbnail() {
    return Container(
      color: AppColors.divider,
      child: const Center(
        child: Icon(
          Icons.broken_image_rounded,
          color: AppColors.hintColor,
          size: 26,
        ),
      ),
    );
  }
}
