import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String _tokenKey = 'auth_token';
  static const String _userIdKey = 'auth_user_id';
  static const String _usernameKey = 'auth_username';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<void> saveSession({
    required int userId,
    required String username,
    required String token,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_userIdKey, userId);
    await preferences.setString(_usernameKey, username);
    await _secureStorage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return _secureStorage.read(key: _tokenKey);
  }

  Future<int?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(_userIdKey);
  }

  Future<String?> getUsername() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(_usernameKey);
  }

  Future<bool> hasActiveSession() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  Future<void> clearSession() async {
    final preferences = await SharedPreferences.getInstance();
    await _secureStorage.delete(key: _tokenKey);
    await preferences.remove(_userIdKey);
    await preferences.remove(_usernameKey);
  }
}
