import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_data_source.dart';
import '../../../../core/storage/token_storage.dart';

class AuthRepositoryImpl implements AuthRepository {
  const AuthRepositoryImpl(this._remoteDataSource, this._tokenStorage);

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  @override
  Future<AuthSession> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    final session = await _remoteDataSource.register({
      'full_name': fullName,
      'username': username,
      'email': email,
      'password': password,
    });
    await _saveSession(session);
    return session;
  }

  @override
  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    final session = await _remoteDataSource.login({
      'email': email,
      'password': password,
      'remember_me': rememberMe,
    });
    await _saveSession(session);
    return session;
  }

  @override
  Future<void> forgotPassword(String email) {
    return _remoteDataSource.forgotPassword({'email': email});
  }

  @override
  Future<void> resetPassword({
    required String token,
    required String password,
  }) {
    return _remoteDataSource.resetPassword({
      'token': token,
      'password': password,
    });
  }

  @override
  Future<void> verifyEmail({required String email, required String code}) {
    return _remoteDataSource.verifyEmail({'email': email, 'code': code});
  }

  @override
  Future<AuthSession> refreshToken(String refreshToken) async {
    final session = await _remoteDataSource.refreshToken({
      'refresh_token': refreshToken,
    });
    await _saveSession(session);
    return session;
  }

  @override
  Future<void> logout() async {
    await _remoteDataSource.logout();
    await _tokenStorage.clear();
  }

  Future<void> _saveSession(AuthSession session) {
    return _tokenStorage.saveTokens(
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
    );
  }
}
