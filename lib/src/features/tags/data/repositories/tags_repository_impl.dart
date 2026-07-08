import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/tag.dart';
import '../../domain/repositories/tags_repository.dart';
import '../models/tag_model.dart';

class TagsRepositoryImpl implements TagsRepository {
  const TagsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Tag>> getTags({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.tags,
      queryParameters: {'page': page, 'limit': limit},
    );
    return ApiResponseParser.unwrapList(response.data)
        .map(
          (item) => TagModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<Tag> createTag({
    required String name,
    required String colorHex,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.tags,
      data: {'name': name, 'color_hex': colorHex},
    );
    return TagModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }
}
