import 'package:equatable/equatable.dart';

import '../../../../core/domain/entity_status.dart';

enum TaskPriority { low, medium, high, urgent }

class TaskItem extends Equatable {
  const TaskItem({
    required this.id,
    required this.taskListId,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    this.description,
    this.priority = TaskPriority.medium,
    this.deadline,
    this.reminderAt,
    this.repeatRule,
    this.isCompleted = false,
    this.isFavorite = false,
    this.status = EntityStatus.active,
  });

  final String id;
  final String taskListId;
  final String title;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;
  final TaskPriority priority;
  final DateTime? deadline;
  final DateTime? reminderAt;
  final String? repeatRule;
  final bool isCompleted;
  final bool isFavorite;
  final EntityStatus status;

  @override
  List<Object?> get props => [
    id,
    taskListId,
    title,
    createdAt,
    updatedAt,
    description,
    priority,
    deadline,
    reminderAt,
    repeatRule,
    isCompleted,
    isFavorite,
    status,
  ];
}
