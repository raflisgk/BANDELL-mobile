import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';

/// Helper untuk kompresi foto dokumentasi sebelum di-upload ke server.
class ImageCompressHelper {
  /// Kompresi satu file foto lokal.
  /// Mengembalikan path file hasil kompresi, atau path awal jika gagal / tidak perlu dikompres.
  static Future<String> compressImage(
    String filePath, {
    int quality = 75,
    int minWidth = 1080,
    int minHeight = 1080,
  }) async {
    try {
      final trimmed = filePath.trim();
      if (trimmed.isEmpty) return filePath;

      // Jangan kompres jika URL remote (misal foto yang sudah ada di server)
      if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
        return filePath;
      }

      final file = File(trimmed);
      if (!await file.exists()) {
        return filePath;
      }

      final originalSize = await file.length();

      // Jika ukuran file sudah sangat kecil (< 150 KB), tidak perlu dikompres ulang
      if (originalSize < 150 * 1024) {
        return filePath;
      }

      final dir = file.parent.path;
      final fileName = file.uri.pathSegments.last;
      final targetPath =
          '$dir/comp_${DateTime.now().millisecondsSinceEpoch}_$fileName';

      final XFile? compressedFile =
          await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        keepExif: false,
      );

      if (compressedFile != null) {
        final resultFile = File(compressedFile.path);
        if (await resultFile.exists()) {
          final compressedSize = await resultFile.length();
          debugPrint(
            '📸 Kompresi Foto Berhasil: ${(originalSize / 1024).toStringAsFixed(1)} KB -> ${(compressedSize / 1024).toStringAsFixed(1)} KB',
          );
          return compressedFile.path;
        }
      }
    } catch (e) {
      debugPrint('⚠️ Gagal mengompres foto ($filePath): $e');
    }

    return filePath;
  }

  /// Kompresi seluruh daftar foto secara sekuensial.
  static Future<List<String>> compressPhotos(
    List<String> photoPaths, {
    int quality = 75,
    int minWidth = 1080,
    int minHeight = 1080,
  }) async {
    final List<String> result = [];
    for (final path in photoPaths) {
      final compressed = await compressImage(
        path,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
      );
      result.add(compressed);
    }
    return result;
  }
}

