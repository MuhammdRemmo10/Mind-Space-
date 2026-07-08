import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class Tag extends Equatable {
  const Tag({
    required this.id,
    required this.name,
    required this.slug,
    required this.color,
    required this.usageCount,
  });

  final String id;
  final String name;
  final String slug;
  final Color color;
  final int usageCount;

  @override
  List<Object?> get props => [id, name, slug, color, usageCount];
}
