import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureCredentialService {
  static const FlutterSecureStorage _storage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      resetOnError: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String _keyRememberMe = 'auth_remember_me';
  static const String _keyEmail = 'auth_saved_email';
  static const String _keyPassword = 'auth_saved_password';
  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserData = 'auth_user_data';

  /// Save login credentials securely
  static Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    await _storage.write(key: _keyRememberMe, value: 'true');
    await _storage.write(key: _keyEmail, value: email);
    await _storage.write(key: _keyPassword, value: password);
  }

  /// Load stored credentials if remember_me was true
  static Future<Map<String, String>?> getSavedCredentials() async {
    final rememberMe = await _storage.read(key: _keyRememberMe);
    if (rememberMe != 'true') {
      return null;
    }

    final email = await _storage.read(key: _keyEmail);
    final password = await _storage.read(key: _keyPassword);

    if (email != null && password != null && email.isNotEmpty && password.isNotEmpty) {
      return {
        'email': email,
        'password': password,
      };
    }

    return null;
  }

  /// Mark session as active or inactive and optionally cache user JSON
  static Future<void> setSession({
    required bool isLoggedIn,
    String? userDataJson,
  }) async {
    await _storage.write(key: _keyIsLoggedIn, value: isLoggedIn ? 'true' : 'false');
    if (userDataJson != null) {
      await _storage.write(key: _keyUserData, value: userDataJson);
    } else if (!isLoggedIn) {
      await _storage.delete(key: _keyUserData);
    }
  }

  /// Check whether an active session exists
  static Future<bool> isSessionActive() async {
    final val = await _storage.read(key: _keyIsLoggedIn);
    return val == 'true';
  }

  /// Retrieve cached user data JSON string if available
  static Future<String?> getUserData() async {
    return await _storage.read(key: _keyUserData);
  }

  /// Delete saved credentials completely
  static Future<void> clearCredentials() async {
    await _storage.delete(key: _keyRememberMe);
    await _storage.delete(key: _keyEmail);
    await _storage.delete(key: _keyPassword);
  }
}
