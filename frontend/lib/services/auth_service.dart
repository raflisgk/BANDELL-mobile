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
    final user = currentUser;
    if (user == null) return null;

    try {
      final response = await ApiService.getProfile(user.idUser);
      final data = response['data'];
      if (data is Map<String, dynamic>) {
        final updated = UserModel(
          idUser: data['id'] is int
              ? data['id']
              : int.tryParse(data['id']?.toString() ?? '') ?? user.idUser,
          username: user.username,
          name: data['name']?.toString() ?? user.name,
          role: user.role,
          email: data['email']?.toString() ?? user.email,
          phone: data['phone_number']?.toString() ?? user.phone,
          placementArea:
              data['placement_area']?.toString() ?? user.placementArea,
        );
        currentUser = updated;
        return updated;
      }
    } catch (e) {
      debugPrint('Error getProfile: $e');
    }
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