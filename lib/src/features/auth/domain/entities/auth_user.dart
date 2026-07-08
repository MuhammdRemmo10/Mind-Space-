import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({
    required this.id,
    required this.fullName,
    required this.username,
    required this.email,
    this.phoneNumber,
    this.country,
    this.biography,
    this.profilePhotoUrl,
    this.coverPhotoUrl,
    this.joinDate,
  });

  final String id;
  final String fullName;
  final String username;
  final String email;
  final String? phoneNumber;
  final String? country;
  final String? biography;
  final String? profilePhotoUrl;
  final String? coverPhotoUrl;
  final DateTime? joinDate;

  @override
  List<Object?> get props => [
    id,
    fullName,
    username,
    email,
    phoneNumber,
    country,
    biography,
    profilePhotoUrl,
    coverPhotoUrl,
    joinDate,
  ];
}
