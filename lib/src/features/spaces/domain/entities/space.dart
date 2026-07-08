import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/domain/entity_status.dart';

class Space extends Equatable {
  const Space({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.isFavorite = false,
    this.isPinned = false,
    this.status = EntityStatus.active,
  });

  final String id;
  final String name;
  final IconData icon;
  final Color color;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final bool isFavorite;
  final bool isPinned;
  final EntityStatus status;

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    color,
    createdAt,
    updatedAt,
    description,
    isFavorite,
    isPinned,
    status,
  ];
}
