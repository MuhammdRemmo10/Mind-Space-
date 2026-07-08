import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/mind_file.dart';
import '../../domain/repositories/files_repository.dart';

class FilesRepositoryImpl implements FilesRepository {
  const FilesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<MindFile>> getFiles({int page = 1, int limit = 20}) async {
    final response = await _dio.get(
      ApiEndpoints.files,
      queryParameters: {'page': page, 'limit': limit},
    );

    return ApiResponseParser.unwrapList(response.data).map((item) {
      final map = Map<String, dynamic>.from(item as Map);
      return MindFile(
        id: map['public_id']?.toString() ?? map['id'].toString(),
        originalName: map['original_name'] as String? ?? '',
        mimeType: map['mime_type'] as String? ?? '',
        fileType: map['file_type'] as String? ?? '',
        fileSize: int.tryParse(map['file_size']?.toString() ?? '') ?? 0,
      );
    }).toList();
  }
}
