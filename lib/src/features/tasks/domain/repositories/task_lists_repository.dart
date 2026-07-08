import '../entities/task_list.dart';

abstract class TaskListsRepository {
  Future<List<TaskList>> getTaskLists({int page = 1, int limit = 100});

  Future<TaskList> createTaskList(TaskList taskList);

  Future<TaskList> updateTaskList(TaskList taskList);

  Future<void> deleteTaskList(String id);
}
