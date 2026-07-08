import 'package:flutter/material.dart';

import '../../../../core/domain/entity_status.dart';
import '../../domain/entities/task_list.dart';

class TaskListModel extends TaskList {
  const TaskListModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.color,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.totalTasks,
    super.completedTasks,
    super.isPinned,
    super.status,
  });

  factory TaskListModel.fromJson(Map<String, dynamic> json) {
    return TaskListModel(
      id: json['public_id']?.toString() ?? json['id'].toString(),
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      icon: _iconFromName(json['icon'] as String?),
      color: _colorFromHex(json['color_hex'] as String?),
      totalTasks: _asInt(json['total_tasks']),
      completedTasks: _asInt(json['completed_tasks']),
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

  static int _asInt(dynamic value) {
    if (value is int) {
      return value;
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static IconData _iconFromName(String? name) {
    return switch (name) {
      'today' => Icons.today_outlined,
      'work' => Icons.work_outline,
      'study' => Icons.school_outlined,
      'home' => Icons.home_outlined,
      _ => Icons.check_circle_outline,
    };
  }

  static Color _colorFromHex(String? value) {
    final hex = (value ?? '#4F46E5').replaceFirst('#', '');
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
