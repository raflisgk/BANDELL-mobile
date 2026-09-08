import '../dummy/dummy_data.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  /// Melakukan autentikasi user ke Laravel API
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // Siap diganti dengan HTTP POST request ke API Laravel
    await Future.delayed(const Duration(milliseconds: 600));

    // Fallback data dummy saat ini
    final user = DummyData.users.firstWhere(
      (u) => u.username == username,
      orElse: () => DummyData.currentUser,
    );
    ApiService.setAuthToken('dummy_token_${user.idUser}');
    DummyData.currentUser = user;
    return user;
  }

  /// Menghapus sesi dan token autentikasi
  Future<void> logout() async {
    // Siap diganti dengan HTTP POST request ke API Laravel (/logout)
    await Future.delayed(const Duration(milliseconds: 300));
    ApiService.setAuthToken(null);
  }

  /// Mengambil data profile pengguna saat ini
  Future<UserModel> getProfile() async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/me atau /profile)
    await Future.delayed(const Duration(milliseconds: 300));
    return DummyData.currentUser;
  }

  /// Memperbarui nomor telepon profil
  Future<bool> updatePhone(String newPhone) async {
    // Siap diganti dengan HTTP PUT/POST request ke API Laravel
    await Future.delayed(const Duration(milliseconds: 400));
    return true;
  }
}
