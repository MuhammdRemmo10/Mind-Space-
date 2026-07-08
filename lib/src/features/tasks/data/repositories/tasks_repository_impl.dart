import 'package:dio/dio.dart';

import '../../../../core/domain/entity_status.dart';
import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/repositories/tasks_repository.dart';
import '../models/task_item_model.dart';

class TasksRepositoryImpl implements TasksRepository {
  const TasksRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TaskItem>> getTasks({
    String? taskListId,
    EntityStatus? status,
    bool favoritesOnly = false,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParameters = <String, dynamic>{'page': page, 'limit': limit};
    if (taskListId != null) {
      queryParameters['task_list_id'] = taskListId;
    }
    if (status != null) {
      queryParameters['status'] = status.name;
    }
    if (favoritesOnly) {
      queryParameters['favorite'] = 1;
    }

    final response = await _dio.get(
      ApiEndpoints.tasks,
      queryParameters: queryParameters,
    );
    return ApiResponseParser.unwrapList(response.data)
        .map(
          (item) =>
              TaskItemModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<TaskItem> createTask(TaskItem task) async {
    final response = await _dio.post(
      ApiEndpoints.tasks,
      data: {
        'task_list_id': task.taskListId,
        'title': task.title,
        'description': task.description,
        'priority': task.priority.name,
        'deadline_at': task.deadline?.toIso8601String(),
        'reminder_at': task.reminderAt?.toIso8601String(),
        'repeat_rule': task.repeatRule,
      },
    );
    return TaskItemModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<void> archiveTask(String id) async {
    final response = await _dio.patch(
      ApiEndpoints.tasks,
      data: {'id': id, 'action': 'archive'},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<void> completeTask(String id, {required bool isCompleted}) async {
    final response = await _dio.patch(
      ApiEndpoints.tasks,
      data: {'id': id, 'is_completed': isCompleted},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<void> favoriteTask(String id, {required bool isFavorite}) async {
    final response = await _dio.patch(
      ApiEndpoints.tasks,
      data: {'id': id, 'action': 'favorite', 'is_favorite': isFavorite},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<void> deleteTask(String id) async {
    final response = await _dio.delete(ApiEndpoints.tasks, data: {'id': id});
    ApiResponseParser.unwrapVoid(response.data);
  }

  @override
  Future<void> restoreTask(String id) async {
    final response = await _dio.patch(
      ApiEndpoints.tasks,
      data: {'id': id, 'action': 'restore'},
    );
    ApiResponseParser.unwrapMap(response.data);
  }

  @override
  Future<TaskItem> updateTask(TaskItem task) => throw UnimplementedError();
}
