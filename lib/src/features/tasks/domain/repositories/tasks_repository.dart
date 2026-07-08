import '../../../../core/domain/entity_status.dart';
import '../entities/task_item.dart';

abstract class TasksRepository {
  Future<List<TaskItem>> getTasks({
    String? taskListId,
    EntityStatus? status,
    bool favoritesOnly = false,
    int page = 1,
    int limit = 20,
  });

  Future<TaskItem> createTask(TaskItem task);
  Future<TaskItem> updateTask(TaskItem task);
  Future<void> completeTask(String id, {required bool isCompleted});
  Future<void> favoriteTask(String id, {required bool isFavorite});
  Future<void> archiveTask(String id);
  Future<void> deleteTask(String id);
  Future<void> restoreTask(String id);
}
