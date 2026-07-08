import '../entities/auth_session.dart';

abstract class AuthRepository {
  Future<AuthSession> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  });

  Future<AuthSession> login({
    required String email,
    required String password,
    required bool rememberMe,
  });

  Future<void> forgotPassword(String email);
  Future<void> resetPassword({required String token, required String password});
  Future<void> verifyEmail({required String email, required String code});
  Future<AuthSession> refreshToken(String refreshToken);
  Future<void> logout();
}
