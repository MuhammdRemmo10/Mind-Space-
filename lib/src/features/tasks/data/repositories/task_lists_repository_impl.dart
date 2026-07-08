import 'package:dio/dio.dart';

import '../../../../core/network/api_endpoints.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../domain/entities/task_list.dart';
import '../../domain/repositories/task_lists_repository.dart';
import '../models/task_list_model.dart';

class TaskListsRepositoryImpl implements TaskListsRepository {
  const TaskListsRepositoryImpl(this._dio);

  final Dio _dio;

  @override
  Future<List<TaskList>> getTaskLists({int page = 1, int limit = 100}) async {
    final response = await _dio.get(
      ApiEndpoints.taskLists,
      queryParameters: {'page': page, 'limit': limit},
    );
    return ApiResponseParser.unwrapList(response.data)
        .map(
          (item) =>
              TaskListModel.fromJson(Map<String, dynamic>.from(item as Map)),
        )
        .toList();
  }

  @override
  Future<TaskList> createTaskList(TaskList taskList) async {
    final response = await _dio.post(
      ApiEndpoints.taskLists,
      data: {
        'name': taskList.name,
        'description': taskList.description,
        'icon': 'check_circle',
        'color_hex':
            '#${taskList.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
      },
    );
    return TaskListModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<TaskList> updateTaskList(TaskList taskList) async {
    final response = await _dio.put(
      ApiEndpoints.taskLists,
      data: {
        'id': taskList.id,
        'name': taskList.name,
        'description': taskList.description,
        'icon': 'check_circle',
        'color_hex':
            '#${taskList.color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
        'is_pinned': taskList.isPinned,
      },
    );
    return TaskListModel.fromJson(ApiResponseParser.unwrapMap(response.data));
  }

  @override
  Future<void> deleteTaskList(String id) async {
    final response = await _dio.delete(
      ApiEndpoints.taskLists,
      data: {'id': id},
    );
    ApiResponseParser.unwrapVoid(response.data);
  }
}
