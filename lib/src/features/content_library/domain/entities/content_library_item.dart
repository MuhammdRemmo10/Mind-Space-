import 'package:equatable/equatable.dart';

import '../../../../core/domain/entity_status.dart';

enum ContentLibraryItemType { note, task, article }

enum ContentLibraryMode { favorites, archive, trash }

class ContentLibraryItem extends Equatable {
  const ContentLibraryItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.type,
    required this.status,
    required this.isFavorite,
    required this.updatedAt,
    this.coverImageUrl,
  });

  final String id;
  final String title;
  final String subtitle;
  final ContentLibraryItemType type;
  final EntityStatus status;
  final bool isFavorite;
  final DateTime updatedAt;
  final String? coverImageUrl;

  @override
  List<Object?> get props => [
    id,
    title,
    subtitle,
    type,
    status,
    isFavorite,
    updatedAt,
    coverImageUrl,
  ];
}
