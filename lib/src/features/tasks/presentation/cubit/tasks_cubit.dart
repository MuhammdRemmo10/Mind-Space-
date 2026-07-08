import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_list.dart';
import '../../domain/repositories/task_lists_repository.dart';
import '../../domain/repositories/tasks_repository.dart';
import 'tasks_state.dart';

class TasksCubit extends Cubit<TasksState> {
  TasksCubit(this._tasksRepository, this._taskListsRepository)
    : super(const TasksInitial());

  final TasksRepository _tasksRepository;
  final TaskListsRepository _taskListsRepository;

  Future<void> load({
    String? taskListId,
    String defaultTaskListName = 'Günlük',
    String defaultTaskListDescription = 'Günlük görevlerin',
  }) async {
    emit(const TasksLoading());

    try {
      var taskLists = await _taskListsRepository.getTaskLists(limit: 100);
      if (taskLists.isEmpty) {
        await _taskListsRepository.createTaskList(
          TaskList(
            id: '',
            name: defaultTaskListName,
            description: defaultTaskListDescription,
            icon: Icons.today_outlined,
            color: AppColors.primary,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        );
        taskLists = await _taskListsRepository.getTaskLists(limit: 100);
      }

      final selectedTaskListId =
          taskListId ?? (taskLists.isNotEmpty ? taskLists.first.id : null);
      final tasks = selectedTaskListId == null
          ? <TaskItem>[]
          : await _tasksRepository.getTasks(
              taskListId: selectedTaskListId,
              limit: 100,
            );

      emit(
        TasksLoaded(
          tasks: tasks,
          taskLists: taskLists,
          selectedTaskListId: selectedTaskListId,
        ),
      );
    } catch (_) {
      emit(const TasksFailure('Görevler yüklenemedi.'));
    }
  }

  Future<void> createTaskList({
    required String name,
    String? description,
    required Color color,
  }) async {
    try {
      final taskList = await _taskListsRepository.createTaskList(
        TaskList(
          id: '',
          name: name,
          description: description,
          icon: Icons.check_circle_outline,
          color: color,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await load(taskListId: taskList.id);
    } catch (_) {
      emit(const TasksFailure('Görev listesi oluşturulamadı.'));
    }
  }

  Future<void> create({
    required String taskListId,
    required String title,
    String? description,
    required TaskPriority priority,
  }) async {
    try {
      await _tasksRepository.createTask(
        TaskItem(
          id: '',
          taskListId: taskListId,
          title: title,
          description: description,
          priority: priority,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await load(taskListId: taskListId);
    } catch (_) {
      emit(const TasksFailure('Görev oluşturulamadı.'));
    }
  }

  Future<void> complete(String taskId, bool isCompleted) async {
    final current = state;
    if (current is! TasksLoaded) {
      return;
    }

    try {
      await _tasksRepository.completeTask(taskId, isCompleted: isCompleted);
      await load(taskListId: current.selectedTaskListId);
    } catch (_) {
      emit(const TasksFailure('Görev durumu güncellenemedi.'));
    }
  }

  Future<void> delete(String taskId) async {
    final current = state;
    if (current is! TasksLoaded) {
      return;
    }

    try {
      await _tasksRepository.deleteTask(taskId);
      await load(taskListId: current.selectedTaskListId);
    } catch (_) {
      emit(const TasksFailure('Görev silinemedi.'));
    }
  }

  Future<void> favorite(String taskId, bool isFavorite) async {
    final current = state;
    if (current is! TasksLoaded) {
      return;
    }

    try {
      await _tasksRepository.favoriteTask(taskId, isFavorite: isFavorite);
      await load(taskListId: current.selectedTaskListId);
    } catch (_) {
      emit(const TasksFailure('Görev güncellenemedi.'));
    }
  }

  Future<void> archive(String taskId) async {
    final current = state;
    if (current is! TasksLoaded) {
      return;
    }

    try {
      await _tasksRepository.archiveTask(taskId);
      await load(taskListId: current.selectedTaskListId);
    } catch (_) {
      emit(const TasksFailure('Görev arşivlenemedi.'));
    }
  }
}
