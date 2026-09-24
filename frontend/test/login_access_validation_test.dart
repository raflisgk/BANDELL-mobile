import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_teknisi/models/user_model.dart';
import 'package:mobile_teknisi/services/api_service.dart';

void main() {
  group('Login Access Validation & Error Mapping Tests', () {
    test('ApiException stores message and statusCode correctly', () {
      const e = ApiException('Akun ini tidak dapat digunakan pada aplikasi teknisi.', statusCode: 403);
      expect(e.message, 'Akun ini tidak dapat digunakan pada aplikasi teknisi.');
      expect(e.statusCode, 403);
      expect(e.toString(), 'Akun ini tidak dapat digunakan pada aplikasi teknisi.');
    });

    test('403 Role restriction message format', () {
      const e = ApiException('Akun ini tidak dapat digunakan pada aplikasi teknisi.', statusCode: 403);
      expect(e.message, contains('aplikasi teknisi'));
      expect(e.statusCode, 403);
    });

    test('403 Inactive account message format', () {
      const e = ApiException('Akun Anda sedang nonaktif. Silakan hubungi administrator.', statusCode: 403);
      expect(e.message, contains('nonaktif'));
      expect(e.statusCode, 403);
    });

    test('403 Deleted or not found account message format', () {
      const e = ApiException('Akun tidak ditemukan atau sudah tidak aktif.', statusCode: 403);
      expect(e.message, contains('tidak aktif'));
      expect(e.statusCode, 403);
    });

    test('401 Wrong credentials message format', () {
      const e = ApiException('Email atau password salah.', statusCode: 401);
      expect(e.message, 'Email atau password salah.');
      expect(e.statusCode, 401);
    });

    test('UserModel parses technician role and status correctly from API response', () {
      final json = {
        'id': 4,
        'id_user': 4,
        'name': 'Budi Santoso',
        'email': 'budi@example.com',
        'role': 'teknisi',
        'status': 'Aktif',
        'phone': '081234567890',
        'placement_area': 'Surabaya',
      };

      final user = UserModel.fromJson(json);
      expect(user.idUser, 4);
      expect(user.role, 'teknisi');
      expect(user.name, 'Budi Santoso');
      expect(user.phone, '081234567890');
    });
  });
}

