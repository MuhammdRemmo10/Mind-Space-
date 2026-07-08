import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/generated/app_localizations.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_entry.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/task_item.dart';
import '../../domain/entities/task_list.dart';
import '../cubit/tasks_cubit.dart';
import '../cubit/tasks_state.dart';

class TasksPage extends StatelessWidget {
  const TasksPage({this.initialTaskListId, super.key});

  final String? initialTaskListId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return BlocProvider(
      create: (_) => sl<TasksCubit>()
        ..load(
          taskListId: initialTaskListId,
          defaultTaskListName: l10n.defaultTaskListName,
          defaultTaskListDescription: l10n.defaultTaskListDescription,
        ),
      child: const _TasksView(),
    );
  }
}

class _TasksView extends StatelessWidget {
  const _TasksView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: RefreshIndicator(
            onRefresh: () {
              final state = context.read<TasksCubit>().state;
              final taskListId = state is TasksLoaded
                  ? state.selectedTaskListId
                  : null;
              return context.read<TasksCubit>().load(
                taskListId: taskListId,
                defaultTaskListName: context.l10n.defaultTaskListName,
                defaultTaskListDescription:
                    context.l10n.defaultTaskListDescription,
              );
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      onCreateTaskList: () => _showCreateTaskListSheet(context),
                      onCreateTask: () => _showCreateTaskSheet(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                  sliver: BlocBuilder<TasksCubit, TasksState>(
                    builder: (context, state) {
                      if (state is TasksLoading || state is TasksInitial) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is TasksFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(context.l10n.tasksLoadFailed),
                          ),
                        );
                      }

                      final loaded = state as TasksLoaded;
                      final selectedTaskList = _selectedTaskList(loaded);
                      final completedCount = loaded.tasks
                          .where((task) => task.isCompleted)
                          .length;
                      final completion = loaded.tasks.isEmpty
                          ? 0
                          : ((completedCount / loaded.tasks.length) * 100)
                                .round();

                      return SliverList.list(
                        children: [
                          _TaskListSelector(
                            taskLists: loaded.taskLists,
                            selectedTaskListId: loaded.selectedTaskListId,
                            onChanged: (taskListId) =>
                                context.read<TasksCubit>().load(
                                  taskListId: taskListId,
                                  defaultTaskListName:
                                      context.l10n.defaultTaskListName,
                                  defaultTaskListDescription:
                                      context.l10n.defaultTaskListDescription,
                                ),
                            onCreate: () => _showCreateTaskListSheet(context),
                          ),
                          SizedBox(height: AppSizes.md.h),
                          _CompletionCard(
                            completed: completedCount,
                            total: loaded.tasks.length,
                            percentage: completion,
                            taskListName: selectedTaskList?.name,
                          ),
                          SizedBox(height: AppSizes.lg.h),
                          if (loaded.tasks.isEmpty)
                            _EmptyTasks(
                              onCreate: () => _showCreateTaskSheet(context),
                            )
                          else
                            for (
                              var index = 0;
                              index < loaded.tasks.length;
                              index++
                            )
                              Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.md.h),
                                child: AnimatedEntry(
                                  index: index,
                                  child: _TaskCard(
                                    task: loaded.tasks[index],
                                    onOpen: () => _openTaskDetail(
                                      context,
                                      loaded.tasks[index],
                                    ),
                                    onToggle: (value) =>
                                        context.read<TasksCubit>().complete(
                                          loaded.tasks[index].id,
                                          value,
                                        ),
                                    onFavorite: () =>
                                        context.read<TasksCubit>().favorite(
                                          loaded.tasks[index].id,
                                          !loaded.tasks[index].isFavorite,
                                        ),
                                    onArchive: () => context
                                        .read<TasksCubit>()
                                        .archive(loaded.tasks[index].id),
                                    onDelete: () => context
                                        .read<TasksCubit>()
                                        .delete(loaded.tasks[index].id),
                                  ),
                                ),
                              ),
                        ],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  TaskList? _selectedTaskList(TasksLoaded loaded) {
    for (final taskList in loaded.taskLists) {
      if (taskList.id == loaded.selectedTaskListId) {
        return taskList;
      }
    }
    return null;
  }

  void _showCreateTaskListSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TasksCubit>(),
        child: const _CreateTaskListSheet(),
      ),
    );
  }

  void _showCreateTaskSheet(BuildContext context) {
    final state = context.read<TasksCubit>().state;
    if (state is TasksLoaded && state.taskLists.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.tasksNeedList)));
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<TasksCubit>(),
        child: const _CreateTaskSheet(),
      ),
    );
  }

  void _openTaskDetail(BuildContext context, TaskItem task) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, _) => BlocProvider.value(
          value: context.read<TasksCubit>(),
          child: _TaskDetailPage(task: task),
        ),
        transitionsBuilder: (_, animation, _, child) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: curved,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.04),
                end: Offset.zero,
              ).animate(curved),
              child: child,
            ),
          );
        },
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreateTaskList, required this.onCreateTask});

  final VoidCallback onCreateTaskList;
  final VoidCallback onCreateTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.tasks,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: AppSizes.xs.h),
        Text(
          l10n.tasksSubtitle,
          style: theme.textTheme.bodyMedium?.copyWith(color: AppColors.slate),
        ),
        SizedBox(height: AppSizes.md.h),
        Wrap(
          spacing: AppSizes.sm.w,
          runSpacing: AppSizes.sm.h,
          children: [
            AppButton(
              label: l10n.createTask,
              icon: Icons.add,
              onPressed: onCreateTask,
            ),
            AppButton(
              label: l10n.createList,
              icon: Icons.playlist_add,
              style: AppButtonStyle.tonal,
              onPressed: onCreateTaskList,
            ),
          ],
        ),
      ],
    );
  }
}

class _TaskListSelector extends StatelessWidget {
  const _TaskListSelector({
    required this.taskLists,
    required this.selectedTaskListId,
    required this.onChanged,
    required this.onCreate,
  });

  final List<TaskList> taskLists;
  final String? selectedTaskListId;
  final ValueChanged<String> onChanged;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 108.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: taskLists.length + 1,
        separatorBuilder: (context, index) => SizedBox(width: AppSizes.sm.w),
        itemBuilder: (context, index) {
          if (index == taskLists.length) {
            return _CreateListCard(onTap: onCreate);
          }

          final taskList = taskLists[index];
          final selected = selectedTaskListId == taskList.id;
          return _TaskListCard(
            taskList: taskList,
            selected: selected,
            onTap: () => onChanged(taskList.id),
          );
        },
      ),
    );
  }
}

class _TaskListCard extends StatelessWidget {
  const _TaskListCard({
    required this.taskList,
    required this.selected,
    required this.onTap,
  });

  final TaskList taskList;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SizedBox(
      width: 182.w,
      child: AppCard(
        onTap: onTap,
        color: selected ? AppColors.softBlue : Colors.white,
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: taskList.color.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
              ),
              child: Icon(taskList.icon, color: taskList.color, size: 22.sp),
            ),
            SizedBox(width: AppSizes.sm.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    taskList.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    l10n.taskProgress(
                      taskList.completedTasks,
                      taskList.totalTasks,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: AppColors.slate),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateListCard extends StatelessWidget {
  const _CreateListCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 132.w,
      child: AppCard(
        onTap: onTap,
        color: AppColors.softBlue,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add, color: AppColors.primary),
            SizedBox(height: 6.h),
            Text(
              context.l10n.newList,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({
    required this.completed,
    required this.total,
    required this.percentage,
    required this.taskListName,
  });

  final int completed;
  final int total;
  final int percentage;
  final String? taskListName;

  @override
  Widget build(BuildContext context) {
    final isDone = total > 0 && percentage == 100;
    final l10n = context.l10n;

    return AppCard(
      color: isDone ? AppColors.mint.withValues(alpha: 0.10) : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.w,
                decoration: BoxDecoration(
                  color: (isDone ? AppColors.mint : AppColors.primary)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                ),
                child: Icon(
                  isDone ? Icons.verified_outlined : Icons.timeline_outlined,
                  color: isDone ? AppColors.mint : AppColors.primary,
                ),
              ),
              SizedBox(width: AppSizes.md.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isDone ? l10n.listFullyCompleted : l10n.completionStatus,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      taskListName == null
                          ? l10n.noListSelected
                          : l10n.taskListProgressSentence(
                              taskListName!,
                              completed,
                              total,
                            ),
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: AppColors.slate),
                    ),
                  ],
                ),
              ),
              Text(
                l10n.percentageValue(percentage),
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: isDone ? AppColors.mint : AppColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            child: LinearProgressIndicator(
              minHeight: 8.h,
              value: percentage / 100,
              backgroundColor: AppColors.softBlue,
            ),
          ),
        ],
      ),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({
    required this.task,
    required this.onOpen,
    required this.onToggle,
    required this.onFavorite,
    required this.onArchive,
    required this.onDelete,
  });

  final TaskItem task;
  final VoidCallback onOpen;
  final ValueChanged<bool> onToggle;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final priority = _priorityView(task.priority, l10n);

    return Hero(
      tag: 'task-card-${task.id}',
      child: Material(
        color: Colors.transparent,
        child: AppCard(
          onTap: onOpen,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: task.isCompleted,
                onChanged: (value) => onToggle(value ?? false),
              ),
              SizedBox(width: AppSizes.xs.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            task.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  decoration: task.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                                ),
                          ),
                        ),
                        _PriorityBadge(
                          label: priority.label,
                          color: priority.color,
                        ),
                      ],
                    ),
                    if (task.description?.isNotEmpty == true) ...[
                      SizedBox(height: AppSizes.xs.h),
                      Text(
                        task.description!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.slate,
                        ),
                      ),
                    ],
                    SizedBox(height: AppSizes.sm.h),
                    Text(
                      task.isCompleted
                          ? l10n.taskCompletedSentence
                          : l10n.taskIncompleteSentence,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: task.isCompleted
                            ? AppColors.mint
                            : AppColors.slate,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.operations,
                onSelected: (value) {
                  if (value == 'favorite') {
                    onFavorite();
                  } else if (value == 'archive') {
                    onArchive();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'favorite',
                    child: Text(
                      task.isFavorite
                          ? l10n.removeFromFavorites
                          : l10n.addToFavorites,
                    ),
                  ),
                  PopupMenuItem(value: 'archive', child: Text(l10n.archive)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.trash)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  ({String label, Color color}) _priorityView(
    TaskPriority priority,
    AppLocalizations l10n,
  ) {
    return switch (priority) {
      TaskPriority.low => (label: l10n.lowPriority, color: AppColors.mint),
      TaskPriority.medium => (
        label: l10n.mediumPriority,
        color: AppColors.blue,
      ),
      TaskPriority.high => (label: l10n.highPriority, color: AppColors.amber),
      TaskPriority.urgent => (
        label: l10n.urgentPriority,
        color: AppColors.coral,
      ),
    };
  }
}

class _TaskDetailPage extends StatelessWidget {
  const _TaskDetailPage({required this.task});

  final TaskItem task;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final priority = _priorityView(task.priority, l10n);
    final completion = task.isCompleted ? 100 : 0;

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Row(
                    children: [
                      IconButton(
                        tooltip: l10n.back,
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back),
                      ),
                      SizedBox(width: AppSizes.xs.w),
                      Expanded(
                        child: Text(
                          l10n.taskDetails,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: task.isFavorite
                            ? l10n.removeFromFavorites
                            : l10n.addToFavorites,
                        icon: Icon(
                          task.isFavorite ? Icons.star : Icons.star_border,
                        ),
                        onPressed: () async {
                          await context.read<TasksCubit>().favorite(
                            task.id,
                            !task.isFavorite,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      IconButton(
                        tooltip: l10n.archive,
                        icon: const Icon(Icons.archive_outlined),
                        onPressed: () async {
                          await context.read<TasksCubit>().archive(task.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await context.read<TasksCubit>().delete(task.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                ),
                SliverToBoxAdapter(child: SizedBox(height: AppSizes.md.h)),
                SliverToBoxAdapter(
                  child: Hero(
                    tag: 'task-card-${task.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: AppCard(
                        color: task.isCompleted
                            ? AppColors.mint.withValues(alpha: 0.08)
                            : null,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    task.title,
                                    style: theme.textTheme.headlineSmall
                                        ?.copyWith(
                                          fontWeight: FontWeight.w900,
                                          decoration: task.isCompleted
                                              ? TextDecoration.lineThrough
                                              : null,
                                        ),
                                  ),
                                ),
                                _PriorityBadge(
                                  label: priority.label,
                                  color: priority.color,
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizes.lg.h),
                            Text(
                              task.description?.isNotEmpty == true
                                  ? task.description!
                                  : l10n.contentMissing,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.55,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            SizedBox(height: AppSizes.lg.h),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    l10n.completionStatus,
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                Text(
                                  l10n.percentageValue(completion),
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: task.isCompleted
                                        ? AppColors.mint
                                        : AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizes.sm.h),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm.r,
                              ),
                              child: LinearProgressIndicator(
                                minHeight: 8.h,
                                value: completion / 100,
                                backgroundColor: AppColors.softBlue,
                              ),
                            ),
                            SizedBox(height: AppSizes.md.h),
                            Text(
                              task.isCompleted
                                  ? l10n.taskCompletedSentence
                                  : l10n.taskIncompleteSentence,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: task.isCompleted
                                    ? AppColors.mint
                                    : AppColors.slate,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: AppSizes.lg.h),
                            SizedBox(
                              width: double.infinity,
                              child: AppButton(
                                label: task.isCompleted
                                    ? l10n.markIncomplete
                                    : l10n.markCompleted,
                                icon: task.isCompleted
                                    ? Icons.radio_button_unchecked
                                    : Icons.task_alt,
                                onPressed: () async {
                                  await context.read<TasksCubit>().complete(
                                    task.id,
                                    !task.isCompleted,
                                  );
                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  ({String label, Color color}) _priorityView(
    TaskPriority priority,
    AppLocalizations l10n,
  ) {
    return switch (priority) {
      TaskPriority.low => (label: l10n.lowPriority, color: AppColors.mint),
      TaskPriority.medium => (
        label: l10n.mediumPriority,
        color: AppColors.blue,
      ),
      TaskPriority.high => (label: l10n.highPriority, color: AppColors.amber),
      TaskPriority.urgent => (
        label: l10n.urgentPriority,
        color: AppColors.coral,
      ),
    };
  }
}

class _PriorityBadge extends StatelessWidget {
  const _PriorityBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _EmptyTasks extends StatelessWidget {
  const _EmptyTasks({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        children: [
          Icon(Icons.task_alt, size: 52.sp, color: AppColors.primary),
          SizedBox(height: AppSizes.md.h),
          Text(
            l10n.emptyTasksTitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          SizedBox(height: AppSizes.xs.h),
          Text(
            l10n.emptyTasksSubtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
          ),
          SizedBox(height: AppSizes.md.h),
          AppButton(
            label: l10n.createTask,
            icon: Icons.add,
            onPressed: onCreate,
          ),
        ],
      ),
    );
  }
}

class _CreateTaskListSheet extends StatefulWidget {
  const _CreateTaskListSheet();

  @override
  State<_CreateTaskListSheet> createState() => _CreateTaskListSheetState();
}

class _CreateTaskListSheetState extends State<_CreateTaskListSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  Color _color = AppColors.primary;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final description = _descriptionController.text.trim();
    await context.read<TasksCubit>().createTaskList(
      name: _nameController.text.trim(),
      description: description.isEmpty ? null : description,
      color: _color,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final colors = const [
      AppColors.primary,
      AppColors.secondary,
      AppColors.mint,
      AppColors.amber,
      AppColors.coral,
      AppColors.blue,
    ];

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.createTaskList,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.taskListName,
                  prefixIcon: const Icon(Icons.playlist_add_check),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? l10n.taskListNameRequired
                    : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                minLines: 2,
                maxLines: 3,
              ),
              SizedBox(height: AppSizes.md.h),
              Wrap(
                spacing: AppSizes.sm.w,
                children: colors
                    .map(
                      (color) => ChoiceChip(
                        label: const SizedBox.shrink(),
                        selected: _color == color,
                        avatar: CircleAvatar(backgroundColor: color),
                        onSelected: (_) => setState(() => _color = color),
                      ),
                    )
                    .toList(),
              ),
              SizedBox(height: AppSizes.lg.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.createList,
                  icon: Icons.check,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CreateTaskSheet extends StatefulWidget {
  const _CreateTaskSheet();

  @override
  State<_CreateTaskSheet> createState() => _CreateTaskSheetState();
}

class _CreateTaskSheetState extends State<_CreateTaskSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _taskListId;
  TaskPriority _priority = TaskPriority.medium;

  @override
  void initState() {
    super.initState();
    final state = context.read<TasksCubit>().state;
    if (state is TasksLoaded) {
      _taskListId = state.selectedTaskListId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _taskListId == null) {
      return;
    }

    await context.read<TasksCubit>().create(
      taskListId: _taskListId!,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      priority: _priority,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<TasksCubit>().state;
    final taskLists = state is TasksLoaded ? state.taskLists : <TaskList>[];
    final l10n = context.l10n;

    return Padding(
      padding: EdgeInsets.only(
        left: 20.w,
        right: 20.w,
        top: 20.h,
        bottom: MediaQuery.viewInsetsOf(context).bottom + 20.h,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.createTask,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: AppSizes.md.h),
              DropdownButtonFormField<String>(
                initialValue: _taskListId,
                decoration: InputDecoration(
                  labelText: l10n.taskList,
                  prefixIcon: const Icon(Icons.playlist_add_check),
                ),
                items: taskLists
                    .map(
                      (taskList) => DropdownMenuItem<String>(
                        value: taskList.id,
                        child: Text(taskList.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _taskListId = value),
                validator: (value) =>
                    value == null ? l10n.taskListRequired : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.taskTitle,
                  prefixIcon: const Icon(Icons.check_circle_outline),
                ),
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? l10n.taskTitleRequired
                    : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: l10n.description,
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                minLines: 2,
                maxLines: 4,
              ),
              SizedBox(height: AppSizes.md.h),
              DropdownButtonFormField<TaskPriority>(
                initialValue: _priority,
                decoration: InputDecoration(
                  labelText: l10n.priority,
                  prefixIcon: const Icon(Icons.flag_outlined),
                ),
                items: [
                  DropdownMenuItem(
                    value: TaskPriority.low,
                    child: Text(l10n.lowPriority),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.medium,
                    child: Text(l10n.mediumPriority),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.high,
                    child: Text(l10n.highPriority),
                  ),
                  DropdownMenuItem(
                    value: TaskPriority.urgent,
                    child: Text(l10n.urgentPriority),
                  ),
                ],
                onChanged: (value) =>
                    setState(() => _priority = value ?? TaskPriority.medium),
              ),
              SizedBox(height: AppSizes.lg.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: l10n.save,
                  icon: Icons.check,
                  onPressed: _save,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
