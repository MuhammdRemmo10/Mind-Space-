import 'package:flutter/material.dart';

import '../../../../core/domain/entity_status.dart';
import '../../domain/entities/space.dart';

class SpaceModel extends Space {
  const SpaceModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.isFavorite,
    super.isPinned,
    super.status,
  });

  factory SpaceModel.fromJson(Map<String, dynamic> json) {
    return SpaceModel(
      id: json['public_id']?.toString() ?? json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      icon: _iconFromName(json['icon'] as String?),
      color: _colorFromHex(json['color_hex'] as String?),
      isFavorite: json['is_favorite'].toString() == '1',
      isPinned: json['is_pinned'].toString() == '1',
      status: _statusFromString(json['status'] as String?),
      createdAt:
          DateTime.tryParse(json['created_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      updatedAt:
          DateTime.tryParse(json['updated_at'] as String? ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
    );
  }

  static IconData _iconFromName(String? name) {
    return switch (name) {
      'code' => Icons.code,
      'work' => Icons.work_outline,
      'person' => Icons.person_outline,
      'diary' => Icons.auto_stories_outlined,
      'goals' => Icons.flag_outlined,
      'ideas' => Icons.lightbulb_outline,
      _ => Icons.space_dashboard_outlined,
    };
  }

  static Color _colorFromHex(String? value) {
    final hex = (value ?? '#2E8B74').replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }

  static EntityStatus _statusFromString(String? value) {
    return switch (value) {
      'archived' => EntityStatus.archived,
      'trashed' => EntityStatus.trashed,
      _ => EntityStatus.active,
    };
  }
}
