import 'package:flutter/foundation.dart';
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
    final user = currentUser;

    if (user == null) {
      return false;
    }

    try {
      final response = await ApiService.updateProfilePhone(
        userId: user.idUser,
        phoneNumber: newPhone,
      );

      final data = response['data'];

      if (data is Map<String, dynamic>) {
        currentUser = UserModel.fromJson(data);
      } else {
        currentUser = UserModel(
          idUser: user.idUser,
          username: user.username,
          name: user.name,
          role: user.role,
          email: user.email,
          phone: newPhone,
          placementArea: user.placementArea,
        );
      }

      return true;
    } catch (e) {
      debugPrint('Update phone error: $e');
      return false;
    }
  }
}