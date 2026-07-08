import '../../../../core/domain/entity_status.dart';
import '../../domain/entities/task_item.dart';

class TaskItemModel extends TaskItem {
  const TaskItemModel({
    required super.id,
    required super.taskListId,
    required super.title,
    required super.createdAt,
    required super.updatedAt,
    super.description,
    super.priority,
    super.deadline,
    super.reminderAt,
    super.repeatRule,
    super.isCompleted,
    super.isFavorite,
    super.status,
  });

  factory TaskItemModel.fromJson(Map<String, dynamic> json) {
    return TaskItemModel(
      id: json['public_id']?.toString() ?? json['id'].toString(),
      taskListId:
          json['task_list_public_id']?.toString() ??
          json['task_list_id']?.toString() ??
          json['space_id']?.toString() ??
          '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      priority: _priority(json['priority'] as String?),
      deadline: DateTime.tryParse(json['deadline_at'] as String? ?? ''),
      reminderAt: DateTime.tryParse(json['reminder_at'] as String? ?? ''),
      repeatRule: json['repeat_rule'] as String?,
      isCompleted: json['is_completed'].toString() == '1',
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

  static TaskPriority _priority(String? value) {
    return switch (value) {
      'low' => TaskPriority.low,
      'high' => TaskPriority.high,
      'urgent' => TaskPriority.urgent,
      _ => TaskPriority.medium,
    };
  }

  static EntityStatus _status(String? value) {
    return switch (value) {
      'archived' => EntityStatus.archived,
      'trashed' => EntityStatus.trashed,
      _ => EntityStatus.active,
    };
  }
}
