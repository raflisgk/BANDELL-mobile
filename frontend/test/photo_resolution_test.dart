import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/installation_model.dart';
import 'package:mobile_teknisi/screens/detail_lampu/foto_dokumentasi_card.dart';
import 'package:mobile_teknisi/services/api_service.dart';

void main() {
  group('ApiService.resolvePhotoUrl Tests', () {
    test('Resolves relative path without storage prefix', () {
      final resolved = ApiService.resolvePhotoUrl(
        'installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
      );
      expect(
        resolved,
        'http://192.168.1.44:8000/storage/installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
      );
    });

    test('Resolves relative path with storage/ prefix', () {
      final resolved = ApiService.resolvePhotoUrl(
        'storage/installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
      );
      expect(
        resolved,
        'http://192.168.1.44:8000/storage/installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
      );
    });

    test('Resolves relative path with leading slash /storage/...', () {
      final resolved = ApiService.resolvePhotoUrl(
        '/storage/installations/test_photo.jpg',
      );
      expect(
        resolved,
        'http://192.168.1.44:8000/storage/installations/test_photo.jpg',
      );
    });

    test('Normalizes Windows backslashes in relative path', () {
      final resolved = ApiService.resolvePhotoUrl(
        r'installations\nested\test_photo.jpg',
      );
      expect(
        resolved,
        'http://192.168.1.44:8000/storage/installations/nested/test_photo.jpg',
      );
    });

    test('Replaces localhost and 127.0.0.1 with device-accessible host', () {
      final resolvedLocalhost = ApiService.resolvePhotoUrl(
        'http://localhost:8000/storage/installations/photo.jpg',
      );
      expect(
        resolvedLocalhost,
        'http://192.168.1.44:8000/storage/installations/photo.jpg',
      );

      final resolvedLoopback = ApiService.resolvePhotoUrl(
        'http://127.0.0.1:8000/storage/installations/photo.jpg',
      );
      expect(
        resolvedLoopback,
        'http://192.168.1.44:8000/storage/installations/photo.jpg',
      );
    });

    test('Preserves external full URL', () {
      final resolved = ApiService.resolvePhotoUrl(
        'https://external-cdn.com/images/lampu.png',
      );
      expect(resolved, 'https://external-cdn.com/images/lampu.png');
    });

    test('Preserves local file path on mobile device', () {
      final localAndroid = ApiService.resolvePhotoUrl(
        '/data/user/0/com.example/cache/image_picker_123.jpg',
      );
      expect(
        localAndroid,
        '/data/user/0/com.example/cache/image_picker_123.jpg',
      );
    });

    test('Handles null, empty, or whitespace strings safely', () {
      expect(ApiService.resolvePhotoUrl(null), '');
      expect(ApiService.resolvePhotoUrl(''), '');
      expect(ApiService.resolvePhotoUrl('   '), '');
    });
  });

  group('InstallationModel.fromJson Photo Parsing Tests', () {
    test('Parses array of photo objects from Laravel response', () {
      final json = {
        'id': 31,
        'id_lcu': 'KOTA-001',
        'status': 'active',
        'photos': [
          {
            'id': 12,
            'installation_id': 31,
            'photo_path': 'installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
          },
          {
            'id': 13,
            'installation_id': 31,
            'photo_path': 'installations/another_photo.jpg',
          }
        ],
      };

      final model = InstallationModel.fromJson(json);
      expect(model.photos.length, 2);
      expect(
        model.photos[0],
        'http://192.168.1.44:8000/storage/installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
      );
      expect(
        model.photos[1],
        'http://192.168.1.44:8000/storage/installations/another_photo.jpg',
      );
    });

    test('Parses single photo_url field and single photo_path fallback', () {
      final jsonUrl = {
        'id': 32,
        'photo_url': 'installations/single.jpg',
      };
      final modelUrl = InstallationModel.fromJson(jsonUrl);
      expect(modelUrl.photos.length, 1);
      expect(
        modelUrl.photos.first,
        'http://192.168.1.44:8000/storage/installations/single.jpg',
      );
      expect(
        modelUrl.photoUrl,
        'http://192.168.1.44:8000/storage/installations/single.jpg',
      );

      final jsonPath = {
        'id': 33,
        'photo_path': 'storage/installations/fallback.jpg',
      };
      final modelPath = InstallationModel.fromJson(jsonPath);
      expect(modelPath.photos.length, 1);
      expect(
        modelPath.photos.first,
        'http://192.168.1.44:8000/storage/installations/fallback.jpg',
      );
    });
  });

  group('FotoDokumentasiCard Widget Tests', () {
    testWidgets('Renders empty state when photos list is empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FotoDokumentasiCard(photos: []),
          ),
        ),
      );

      expect(find.text('0 FOTO DOKUMENTASI'), findsOneWidget);
      expect(find.text('Belum ada foto dokumentasi'), findsOneWidget);
    });

    testWidgets('Renders header with photo count when photos exist', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: FotoDokumentasiCard(
              photos: [
                'installations/SO4XPlhjuTYKDdpRc38mUKh1iFLntGveVtgpUe1I.jpg',
                'installations/second.jpg',
              ],
            ),
          ),
        ),
      );

      expect(find.text('2 FOTO DOKUMENTASI'), findsOneWidget);
      expect(find.text('Belum ada foto dokumentasi'), findsNothing);
    });
  });
}

