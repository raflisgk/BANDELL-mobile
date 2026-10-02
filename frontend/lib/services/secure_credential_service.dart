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

  static const String _keyIsLoggedIn = 'auth_is_logged_in';
  static const String _keyUserData = 'auth_user_data';
  static const String _keyAuthToken = 'auth_token';

  /// Save Sanctum auth token securely
  static Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _keyAuthToken, value: token);
  }

  /// Retrieve Sanctum auth token
  static Future<String?> getAuthToken() async {
    return await _storage.read(key: _keyAuthToken);
  }

  /// Clear Sanctum auth token
  static Future<void> clearAuthToken() async {
    await _storage.delete(key: _keyAuthToken);
  }

  /// Clean up any legacy saved credentials (passwords/emails) from the device
  static Future<void> cleanupLegacyCredentials() async {
    try {
      await _storage.delete(key: 'auth_remember_me');
      await _storage.delete(key: 'auth_saved_email');
      await _storage.delete(key: 'auth_saved_password');
    } catch (_) {}
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
      await clearAuthToken();
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
}
