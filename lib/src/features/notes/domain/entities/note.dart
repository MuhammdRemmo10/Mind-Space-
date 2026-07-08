import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';

class Note extends Equatable {
  const Note({
    required this.id,
    required this.spaceId,
    required this.title,
    required this.richText,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.tags = const [],
    this.backgroundColor,
    this.visibility = VisibilityLevel.private,
    this.isFavorite = false,
    this.isChecklist = false,
    this.status = EntityStatus.active,
  });

  final String id;
  final String spaceId;
  final String title;
  final String richText;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final List<String> tags;
  final Color? backgroundColor;
  final VisibilityLevel visibility;
  final bool isFavorite;
  final bool isChecklist;
  final EntityStatus status;

  @override
  List<Object?> get props => [
    id,
    spaceId,
    title,
    richText,
    createdAt,
    updatedAt,
    description,
    tags,
    backgroundColor,
    visibility,
    isFavorite,
    isChecklist,
    status,
  ];
}
