import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  /// Session user yang sedang login saat ini
  static UserModel? currentUser;

  /// Melakukan autentikasi user ke Laravel API
  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    // Siap diganti dengan HTTP POST request ke API Laravel (/login)
    await Future.delayed(const Duration(milliseconds: 600));

    final user = UserModel(
      idUser: 1,
      username: username,
      name: username,
      role: 'teknisi',
    );
    currentUser = user;
    ApiService.setAuthToken('token_${user.idUser}');
    return user;
  }

  /// Menghapus sesi dan token autentikasi
  Future<void> logout() async {
    // Siap diganti dengan HTTP POST request ke API Laravel (/logout)
    await Future.delayed(const Duration(milliseconds: 300));
    currentUser = null;
    ApiService.setAuthToken(null);
  }

  /// Mengambil data profile pengguna saat ini
  Future<UserModel?> getProfile() async {
    // Siap diganti dengan HTTP GET request ke API Laravel (/me atau /profile)
    await Future.delayed(const Duration(milliseconds: 300));
    return currentUser;
  }

  /// Memperbarui nomor telepon profil
  Future<bool> updatePhone(String newPhone) async {
    // Siap diganti dengan HTTP PUT/POST request ke API Laravel (/me/phone)
    await Future.delayed(const Duration(milliseconds: 400));
    if (currentUser != null) {
      currentUser = UserModel(
        idUser: currentUser!.idUser,
        username: currentUser!.username,
        name: currentUser!.name,
        role: currentUser!.role,
        email: currentUser!.email,
        phone: newPhone,
      );
    }
    return true;
  }
}
