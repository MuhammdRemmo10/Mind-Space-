import 'package:flutter/material.dart';

import '../../domain/entities/tag.dart';

class TagModel extends Tag {
  const TagModel({
    required super.id,
    required super.name,
    required super.slug,
    required super.color,
    required super.usageCount,
  });

  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['public_id']?.toString() ?? json['id'].toString(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      color: _colorFromHex(json['color_hex'] as String?),
      usageCount: int.tryParse(json['usage_count']?.toString() ?? '') ?? 0,
    );
  }

  static Color _colorFromHex(String? value) {
    final hex = (value ?? '#59636E').replaceFirst('#', '');
    return Color(int.parse('FF$hex', radix: 16));
  }
}
