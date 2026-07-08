import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../models/auth_session_model.dart';

abstract class AuthRemoteDataSource {
  Future<AuthSessionModel> register(Map<String, dynamic> body);
  Future<AuthSessionModel> login(Map<String, dynamic> body);
  Future<void> forgotPassword(Map<String, dynamic> body);
  Future<void> resetPassword(Map<String, dynamic> body);
  Future<void> verifyEmail(Map<String, dynamic> body);
  Future<AuthSessionModel> refreshToken(Map<String, dynamic> body);
  Future<void> logout();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  const AuthRemoteDataSourceImpl(this._dio);

  final Dio _dio;

  @override
  Future<AuthSessionModel> register(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.register, data: body);
    return AuthSessionModel.fromJson(
      ApiResponseParser.unwrapMap(response.data),
    );
  }

  @override
  Future<AuthSessionModel> login(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.login, data: body);
    return AuthSessionModel.fromJson(
      ApiResponseParser.unwrapMap(response.data),
    );
  }

  @override
  Future<void> forgotPassword(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.forgotPassword, data: body);
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<void> resetPassword(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.resetPassword, data: body);
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<void> verifyEmail(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.verifyEmail, data: body);
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<AuthSessionModel> refreshToken(Map<String, dynamic> body) async {
    final response = await _dio.post(ApiEndpoints.refreshToken, data: body);
    return AuthSessionModel.fromJson(
      ApiResponseParser.unwrapMap(response.data),
    );
  }

  @override
  Future<void> logout() async {
    final response = await _dio.post(ApiEndpoints.logout);
    ApiResponseParser.unwrapVoid(response.data);
  }
}
