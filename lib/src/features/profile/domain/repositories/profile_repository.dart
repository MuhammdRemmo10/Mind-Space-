import '../../../auth/domain/entities/auth_user.dart';

abstract class ProfileRepository {
  Future<AuthUser> getProfile();

  Future<AuthUser> updateProfile({
    required String fullName,
    required String username,
    String? phoneNumber,
    String? country,
    String? biography,
    String? profilePhotoPath,
    String? coverPhotoPath,
  });
}
