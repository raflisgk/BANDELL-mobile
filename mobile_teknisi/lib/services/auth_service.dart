import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  static UserModel? currentUser;

  Future<UserModel> login({
    required String username,
    required String password,
  }) async {
    final response = await ApiService.login(
      email: username,
      password: password,
    );

    final userData = response['user'];

    if (userData == null) {
      throw Exception('Data user tidak ditemukan.');
    }

    final user = UserModel.fromJson(userData);

    currentUser = user;

    return user;
  }

  Future<void> logout() async {
    currentUser = null;
  }

  Future<UserModel?> getProfile() async {
    return currentUser;
  }

  Future<bool> updatePhone(String newPhone) async {
    if (currentUser == null) {
      return false;
    }

    currentUser = UserModel(
      idUser: currentUser!.idUser,
      username: currentUser!.username,
      name: currentUser!.name,
      role: currentUser!.role,
      email: currentUser!.email,
      phone: newPhone,
    );

    return true;
  }
}