import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';
import '../../domain/entities/article.dart';

class ArticleModel extends Article {
  const ArticleModel({
    required super.id,
    required super.spaceId,
    required super.title,
    required super.richText,
    required super.readingTimeMinutes,
    required super.createdAt,
    required super.updatedAt,
    super.coverImageUrl,
    super.tags,
    super.publishDate,
    super.visibility,
    super.isFavorite,
    super.status,
  });

  factory ArticleModel.fromJson(Map<String, dynamic> json) {
    return ArticleModel(
      id: json['public_id']?.toString() ?? json['id'].toString(),
      spaceId: json['space_id']?.toString() ?? '',
      title: json['title'] as String? ?? '',
      richText: json['rich_text'] as String? ?? '',
      readingTimeMinutes:
          int.tryParse(json['reading_time_minutes']?.toString() ?? '') ?? 0,
      coverImageUrl: json['cover_image_url'] as String?,
      tags: const [],
      publishDate: DateTime.tryParse(json['published_at'] as String? ?? ''),
      visibility: _visibility(json['visibility'] as String?),
      isFavorite: json['is_favorite'].toString() == '1',
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
      'draft' => EntityStatus.draft,
      'archived' => EntityStatus.archived,
      'trashed' => EntityStatus.trashed,
      _ => EntityStatus.active,
    };
  }
}
