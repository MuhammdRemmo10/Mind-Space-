import 'package:dio/dio.dart';

import '../../../../core/domain/entity_status.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import '../models/note_model.dart';

class NotesRepositoryImpl implements NotesRepository {
  const NotesRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<Note>> getNotes({
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
      ApiEndpoints.notes,
      queryParameters: queryParameters,
    );
    return ApiResponseParser.unwrapList(response.data)
        .map(
          (item) => NoteModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<Note> createNote(Note note) async {
    final response = await _dio.post(
      ApiEndpoints.notes,
      data: {
        'space_id': note.spaceId,
        'title': note.title,
        'description': note.description,
        'rich_text': note.richText,
        'plain_text': note.richText,
        'visibility': note.visibility.name,
      },
    );
    return NoteModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<void> archiveNote(String id) async {
    final response = await _dio.patch(
      ApiEndpoints.notes,
      data: {'id': id, 'action': 'archive'},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<Note> duplicateNote(String id) => throw UnimplementedError();

  @override
  Future<void> favoriteNote(String id, {required bool isFavorite}) async {
    final response = await _dio.patch(
      ApiEndpoints.notes,
      data: {'id': id, 'action': 'favorite', 'is_favorite': isFavorite},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<void> moveNote({
    required String noteId,
    required String targetSpaceId,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> restoreNote(String id) async {
    final response = await _dio.patch(
      ApiEndpoints.notes,
      data: {'id': id, 'action': 'restore'},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<void> trashNote(String id) async {
    final response = await _dio.delete(ApiEndpoints.notes, data: {'id': id});
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<Note> updateNote(Note note) => throw UnimplementedError();
}
