import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/space.dart';
import '../../domain/repositories/spaces_repository.dart';
import '../models/space_model.dart';

class SpacesRepositoryImpl implements SpacesRepository {
  const SpacesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Space>> getSpaces({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.spaces,
      queryParameters: {'page': page, 'limit': limit},
    );
    return ApiResponseParser.unwrapList(response.data)
        .map(
          (item) => SpaceModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<Space> createSpace(Space space) async {
    final response = await _dio.post(
      ApiEndpoints.spaces,
      data: {
        'name': space.name,
        'description': space.description,
        'icon': 'space_dashboard',
        'color_hex':
            '#${space.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      },
    );
    return SpaceModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<Space> updateSpace(Space space) async {
    final response = await _dio.put(
      ApiEndpoints.spaces,
      data: {
        'id': space.id,
        'name': space.name,
        'description': space.description,
        'icon': 'space_dashboard',
        'color_hex':
            '#${space.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      },
    );
    return SpaceModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<void> archiveSpace(String id) {
    throw UnimplementedError('Archive space endpoint will be connected next.');
  }

  @override
  Future<void> deleteSpace(String id) async {
    final response = await _dio.delete(ApiEndpoints.spaces, data: {'id': id});
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<void> favoriteSpace(String id, {required bool isFavorite}) {
    throw UnimplementedError('Favorite space endpoint will be connected next.');
  }

  @override
  Future<void> pinSpace(String id, {required bool isPinned}) {
    throw UnimplementedError('Pin space endpoint will be connected next.');
  }

  @override
  Future<void> restoreSpace(String id) {
    throw UnimplementedError('Restore space endpoint will be connected next.');
  }
}
