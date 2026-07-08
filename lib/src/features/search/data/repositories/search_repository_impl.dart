import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/search_result.dart';
import '../../domain/repositories/search_repository.dart';

class SearchRepositoryImpl implements SearchRepository {
  const SearchRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<SearchResult>> search(String query) async {
    final response = await _dio.get(
      ApiEndpoints.search,
      queryParameters: {'q': query},
    );

    return ApiResponseParser.unwrapList(response.data).map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return SearchResult(
        id: map['id']?.toString() ?? '',
        type: map['type'] as String? ?? '',
        title: map['title'] as String? ?? '',
        subtitle: map['subtitle'] as String?,
      );
    }).toList();
  }
}
