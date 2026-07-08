import '../../domain/entities/auth_user.dart';

class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.fullName,
    required super.username,
    required super.email,
    super.phoneNumber,
    super.country,
    super.biography,
    super.profilePhotoUrl,
    super.coverPhotoUrl,
    super.joinDate,
  });

  factory AuthUserModel.fromJson(Map<String, dynamic> json) {
    return AuthUserModel(
      id: (json['public_id'] ?? json['id']).toString(),
      fullName: json['full_name'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phone_number'] as String?,
      country: json['country'] as String?,
      biography: json['biography'] as String?,
      profilePhotoUrl: json['profile_photo_url'] as String?,
      coverPhotoUrl: json['cover_photo_url'] as String?,
      joinDate: DateTime.tryParse(json['join_date'] as String? ?? ''),
    );
  }
}
