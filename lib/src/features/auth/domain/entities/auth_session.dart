import 'package:equatable/equatable.dart';

import 'auth_user.dart';

class AuthSession extends Equatable {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String refreshToken;

  @override
  List<Object?> get props => [user, accessToken, refreshToken];
}
