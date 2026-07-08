import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../auth/data/models/auth_user_model.dart';
import '../../../auth/domain/entities/auth_user.dart';
import '../../domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  const ProfileRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthUser> getProfile() async {
    final response = await _dio.get(ApiEndpoints.profile);
    return AuthUserModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<AuthUser> updateProfile({
    required String fullName,
    required String username,
    String? phoneNumber,
    String? country,
    String? biography,
    String? profilePhotoPath,
    String? coverPhotoPath,
  }) async {
    final data = FormData.fromMap({
      'full_name': fullName,
      'username': username,
      'phone_number': phoneNumber,
      'country': country,
      'biography': biography,
      if (profilePhotoPath != null)
        'profile_photo': await MultipartFile.fromFile(profilePhotoPath),
      if (coverPhotoPath != null)
        'cover_photo': await MultipartFile.fromFile(coverPhotoPath),
    });

    final response = await _dio.post(ApiEndpoints.profile, data: data);
    return AuthUserModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }
}
