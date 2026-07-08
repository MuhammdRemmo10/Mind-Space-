import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';
import '../../domain/entities/note.dart';

class NoteModel extends Note {
  const NoteModel({
    required super.id,
    required super.spaceId,
    required super.title,
    required super.richText,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.tags,
    super.backgroundColor,
    super.visibility,
    super.isFavorite,
    super.isChecklist,
    super.status,
  });

  factory NoteModel.fromJson(Map<String, dynamic> json) {
    return NoteModel(
      id: json['public_id']?.toString() ?? json['id'].toString(),
      spaceId: json['space_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      richText: json['rich_text'] as String? ?? '',
      tags: const [],
      backgroundColor: null,
      visibility: _visibility(json['visibility'] as String?),
      isFavorite: json['is_favorite'].toString() == '1',
      isChecklist: json['is_checklist'].toString() == '1',
      status: _status(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static VisibilityLevel _visibility(String? value) {
    return switch (value) {
      'friends' => VisibilityLevel.friends,
      'public' => VisibilityLevel.public,
      _ => VisibilityLevel.private,
    };
  }

  static EntityStatus _status(String? value) {
    return switch (value) {
      'archived' => EntityStatus.archived,
      'trashed' => EntityStatus.trashed,
      _ => EntityStatus.active,
    };
  }
}
