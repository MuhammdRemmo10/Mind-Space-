import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../../../core/domain/entity_status.dart';

class TaskList extends Equatable {
  const TaskList({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.totalTasks = 0,
    this.completedTasks = 0,
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
  final int totalTasks;
  final int completedTasks;
  final bool isPinned;
  final EntityStatus status;

  int get completionPercentage =>
      totalTasks == 0 ? 0 : ((completedTasks / totalTasks) * 100).round();

  @override
  List<Object?> get props => [
    id,
    name,
    icon,
    color,
    createdAt,
    updatedAt,
    description,
    totalTasks,
    completedTasks,
    isPinned,
    status,
  ];
}
