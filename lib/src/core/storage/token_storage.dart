import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  const TokenStorage(this._preferences);

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final SharedPreferences _preferences;

  String? get accessToken => _preferences.getString(_accessTokenKey);
  String? get refreshToken => _preferences.getString(_refreshTokenKey);

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _preferences.setString(_accessTokenKey, accessToken);
    await _preferences.setString(_refreshTokenKey, refreshToken);
  }

  Future<void> clear() async {
    await _preferences.remove(_accessTokenKey);
    await _preferences.remove(_refreshTokenKey);
  }
}
