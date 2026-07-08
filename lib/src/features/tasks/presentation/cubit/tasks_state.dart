import 'package:equatable/equatable.dart';

import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_list.dart';

sealed class TasksState extends Equatable {
  const TasksState();

  @override
  List<Object?> get props => [];
}

class TasksInitial extends TasksState {
  const TasksInitial();
}

class TasksLoading extends TasksState {
  const TasksLoading();
}

class TasksLoaded extends TasksState {
  const TasksLoaded({
    required this.tasks,
    required this.taskLists,
    this.selectedTaskListId,
  });

  final List<TaskItem> tasks;
  final List<TaskList> taskLists;
  final String? selectedTaskListId;

  @override
  List<Object?> get props => [tasks, taskLists, selectedTaskListId];
}

class TasksFailure extends TasksState {
  const TasksFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
