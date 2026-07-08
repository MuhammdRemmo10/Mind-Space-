import 'package:dio/dio.dart';

import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/articles_repository.dart';
import '../models/article_model.dart';

class ArticlesRepositoryImpl implements ArticlesRepository {
  const ArticlesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Article>> getArticles({
    String? spaceId,
    EntityStatus? status,
    bool favoritesOnly = false,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    if (spaceId != null) {
      queryParameters['space_id'] = spaceId;
    }
    if (status != null) {
      queryParameters['status'] = status.name;
    }
    if (favoritesOnly) {
      queryParameters['favorite'] = 1;
    }

    final response = await _dio.get(
      ApiEndpoints.articles,
      queryParameters: queryParameters,
    );
    return ApiResponseParser.unwrapList(response.data)
        .map(
          (item) =>
              ArticleModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<Article> createArticle(
    Article article, {
    String? coverImagePath,
    bool publishNow = false,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.articles,
      data: FormData.fromMap({
        'space_id': article.spaceId,
        'title': article.title,
        'rich_text': article.richText,
        'plain_text': article.richText,
        'visibility': article.visibility.name,
        'publish_now': publishNow ? '1' : '0',
        if (coverImagePath != null)
          'cover_image': await MultipartFile.fromFile(coverImagePath),
      }),
    );
    return ArticleModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<void> archiveArticle(String id) async {
    final response = await _dio.patch(
      ApiEndpoints.articles,
      data: {'id': id, 'action': 'archive'},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<void> deleteArticle(String id) async {
    final response = await _dio.delete(ApiEndpoints.articles, data: {'id': id});
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<void> favoriteArticle(String id, {required bool isFavorite}) async {
    final response = await _dio.patch(
      ApiEndpoints.articles,
      data: {'id': id, 'action': 'favorite', 'is_favorite': isFavorite},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<Article> publishArticle(
    String id, {
    VisibilityLevel? visibility,
  }) async {
    final response = await _dio.patch(
      ApiEndpoints.articles,
      data: {'id': id, if (visibility != null) 'visibility': visibility.name},
    );
    return ArticleModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<void> restoreArticle(String id) async {
    final response = await _dio.patch(
      ApiEndpoints.articles,
      data: {'id': id, 'action': 'restore'},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<Article> updateArticle(Article article) => throw UnimplementedError();
}
