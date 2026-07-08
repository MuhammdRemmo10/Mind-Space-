import 'package:equatable/equatable.dart';

import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';

class Article extends Equatable {
  const Article({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.richText,
    required this.readingTimeMinutes,
    required this.createdAt,
    required this.updatedAt,
    this.coverImageUrl,
    this.tags = const [],
    this.publishDate,
    this.visibility = VisibilityLevel.private,
    this.isFavorite = false,
    this.status = EntityStatus.active,
  });

  final String id;
  final String spaceId;
  final String title;
  final String richText;
  final int readingTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? coverImageUrl;
  final List<String> tags;
  final DateTime? publishDate;
  final VisibilityLevel visibility;
  final bool isFavorite;
  final EntityStatus status;

  @override
  List<Object?> get props => [
    id,
    spaceId,
    title,
    richText,
    readingTimeMinutes,
    createdAt,
    updatedAt,
    coverImageUrl,
    tags,
    publishDate,
    visibility,
    isFavorite,
    status,
  ];
}
