import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/responsive/app_breakpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../settings/presentation/cubit/theme_cubit.dart';
import '../../../spaces/domain/entities/space.dart';
import '../../../spaces/presentation/cubit/spaces_cubit.dart';
import '../../../spaces/presentation/cubit/spaces_state.dart';
import '../../../spaces/presentation/widgets/space_form_sheet.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../cubit/dashboard_cubit.dart';
import '../cubit/dashboard_state.dart';
import '../widgets/dashboard_metric_card.dart';
import '../widgets/recent_items_panel.dart';
import '../widgets/space_preview_card.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    this.onOpenSpaces,
    this.onOpenNotes,
    this.onOpenTasks,
    this.onOpenArticles,
    this.onOpenFiles,
    this.onOpenNotesForSpace,
    super.key,
  });

  final VoidCallback? onOpenSpaces;
  final VoidCallback? onOpenNotes;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenArticles;
  final VoidCallback? onOpenFiles;
  final ValueChanged<String>? onOpenNotesForSpace;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => sl<DashboardCubit>()..load()),
        BlocProvider(create: (_) => sl<SpacesCubit>()..load()),
      ],
      child: _DashboardView(
        onOpenSpaces: onOpenSpaces,
        onOpenNotes: onOpenNotes,
        onOpenTasks: onOpenTasks,
        onOpenArticles: onOpenArticles,
        onOpenFiles: onOpenFiles,
        onOpenNotesForSpace: onOpenNotesForSpace,
      ),
    );
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView({
    required this.onOpenSpaces,
    required this.onOpenNotes,
    required this.onOpenTasks,
    required this.onOpenArticles,
    required this.onOpenFiles,
    required this.onOpenNotesForSpace,
  });

  final VoidCallback? onOpenSpaces;
  final VoidCallback? onOpenNotes;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenArticles;
  final VoidCallback? onOpenFiles;
  final ValueChanged<String>? onOpenNotesForSpace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: RefreshIndicator(
            onRefresh: () async {
              await Future.wait([
                context.read<DashboardCubit>().load(),
                context.read<SpacesCubit>().load(),
              ]);
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: _DashboardHeader(
                      onCreateSpace: () => showSpaceFormSheet(context),
                      onCreateNote: onOpenNotes,
                      onCreateTask: onOpenTasks,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(20.w),
                  sliver: BlocBuilder<DashboardCubit, DashboardState>(
                    builder: (context, state) {
                      if (state is DashboardLoading ||
                          state is DashboardInitial) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is DashboardFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _DashboardError(message: state.message),
                        );
                      }

                      final summary = (state as DashboardLoaded).summary;

                      return SliverList.list(
                        children: [
                          _FocusCard(summary: summary),
                          SizedBox(height: AppSizes.lg.h),
                          _MetricsGrid(
                            summary: summary,
                            onOpenSpaces: onOpenSpaces,
                            onOpenNotes: onOpenNotes,
                            onOpenTasks: onOpenTasks,
                            onOpenArticles: onOpenArticles,
                            onOpenFiles: onOpenFiles,
                          ),
                          SizedBox(height: AppSizes.lg.h),
                          _WorkspaceSection(
                            onOpenSpaces: onOpenSpaces,
                            onOpenNotesForSpace: onOpenNotesForSpace,
                          ),
                          SizedBox(height: AppSizes.lg.h),
                          _KnowledgePanels(
                            summary: summary,
                            onOpenNotes: onOpenNotes,
                            onOpenTasks: onOpenTasks,
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
}

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({
    required this.onCreateSpace,
    required this.onCreateNote,
    required this.onCreateTask,
  });

  final VoidCallback onCreateSpace;
  final VoidCallback? onCreateNote;
  final VoidCallback? onCreateTask;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.appName,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: AppSizes.xs.h),
                  Text(
                    l10n.dashboardSubtitle,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: AppSizes.md.w),
            IconButton.filledTonal(
              tooltip: l10n.changeTheme,
              onPressed: () {
                final cubit = context.read<ThemeCubit>();
                final nextMode = Theme.of(context).brightness == Brightness.dark
                    ? ThemeMode.light
                    : ThemeMode.dark;
                cubit.setThemeMode(nextMode);
              },
              icon: Icon(
                Theme.of(context).brightness == Brightness.dark
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
              ),
            ),
          ],
        ),
        SizedBox(height: AppSizes.lg.h),
        Wrap(
          spacing: AppSizes.sm.w,
          runSpacing: AppSizes.sm.h,
          children: [
            AppButton(
              label: l10n.createSpace,
              icon: Icons.add,
              onPressed: onCreateSpace,
            ),
            AppButton(
              label: l10n.newNote,
              icon: Icons.edit_note,
              style: AppButtonStyle.tonal,
              onPressed: onCreateNote,
            ),
            AppButton(
              label: l10n.newTask,
              icon: Icons.check_circle_outline,
              style: AppButtonStyle.tonal,
              onPressed: onCreateTask,
            ),
          ],
        ),
      ],
    );
  }
}

class _FocusCard extends StatelessWidget {
  const _FocusCard({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;
    final hasActiveSpace =
        summary.mostActiveSpace.isNotEmpty && summary.mostActiveSpace != 'Yok';

    return AppCard(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.34),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            ),
            child: const Icon(Icons.auto_awesome, color: AppColors.primary),
          ),
          SizedBox(width: AppSizes.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasActiveSpace
                      ? l10n.dashboardMostActiveSpace(summary.mostActiveSpace)
                      : l10n.dashboardFocusReady,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSizes.xxs.h),
                Text(
                  l10n.dashboardWritingSummary(
                    summary.writingStreak,
                    summary.totalWordsWritten,
                  ),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricsGrid extends StatelessWidget {
  const _MetricsGrid({
    required this.summary,
    required this.onOpenSpaces,
    required this.onOpenNotes,
    required this.onOpenTasks,
    required this.onOpenArticles,
    required this.onOpenFiles,
  });

  final DashboardSummary summary;
  final VoidCallback? onOpenSpaces;
  final VoidCallback? onOpenNotes;
  final VoidCallback? onOpenTasks;
  final VoidCallback? onOpenArticles;
  final VoidCallback? onOpenFiles;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final l10n = context.l10n;
    final columns = AppBreakpoints.isExpanded(context)
        ? 5
        : AppBreakpoints.isMedium(context)
        ? 3
        : 2;

    return GridView.count(
      crossAxisCount: columns,
      crossAxisSpacing: AppSizes.md.w,
      mainAxisSpacing: AppSizes.md.h,
      childAspectRatio: width >= 700 ? 1.65 : 1.18,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        DashboardMetricCard(
          label: l10n.totalSpaces,
          value: summary.totalSpaces.toString(),
          icon: Icons.space_dashboard_outlined,
          color: AppColors.mint,
          onTap: onOpenSpaces,
        ),
        DashboardMetricCard(
          label: l10n.totalNotes,
          value: summary.totalNotes.toString(),
          icon: Icons.notes_outlined,
          color: AppColors.blue,
          onTap: onOpenNotes,
        ),
        DashboardMetricCard(
          label: l10n.totalTasks,
          value: summary.totalTasks.toString(),
          icon: Icons.check_circle_outline,
          color: AppColors.amber,
          onTap: onOpenTasks,
        ),
        DashboardMetricCard(
          label: l10n.totalArticles,
          value: summary.totalArticles.toString(),
          icon: Icons.article_outlined,
          color: AppColors.coral,
          onTap: onOpenArticles,
        ),
        DashboardMetricCard(
          label: l10n.totalFiles,
          value: summary.totalFiles.toString(),
          icon: Icons.attach_file,
          color: AppColors.violet,
          onTap: onOpenFiles,
        ),
      ],
    );
  }
}

class _WorkspaceSection extends StatelessWidget {
  const _WorkspaceSection({
    required this.onOpenSpaces,
    required this.onOpenNotesForSpace,
  });

  final VoidCallback? onOpenSpaces;
  final ValueChanged<String>? onOpenNotesForSpace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<SpacesCubit, SpacesState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SectionTitle(
              title: l10n.spaces,
              actionLabel: l10n.openAll,
              onAction: onOpenSpaces,
            ),
            SizedBox(height: AppSizes.md.h),
            if (state is SpacesLoading || state is SpacesInitial)
              const Center(child: CircularProgressIndicator())
            else if (state is SpacesFailure)
              AppCard(child: Text(l10n.dashboardDataLoadFailed))
            else
              _SpacesPreviewGrid(
                spaces: (state as SpacesLoaded).spaces.take(6).toList(),
                onCreateSpace: () => showSpaceFormSheet(context),
                onOpenNotesForSpace: onOpenNotesForSpace,
              ),
          ],
        );
      },
    );
  }
}

class _SpacesPreviewGrid extends StatelessWidget {
  const _SpacesPreviewGrid({
    required this.spaces,
    required this.onCreateSpace,
    required this.onOpenNotesForSpace,
  });

  final List<Space> spaces;
  final VoidCallback onCreateSpace;
  final ValueChanged<String>? onOpenNotesForSpace;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    if (spaces.isEmpty) {
      return AppCard(
        child: Row(
          children: [
            const Icon(
              Icons.space_dashboard_outlined,
              color: AppColors.primary,
            ),
            SizedBox(width: AppSizes.md.w),
            Expanded(
              child: Text(
                l10n.emptySpacesPreview,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            SizedBox(width: AppSizes.sm.w),
            AppButton(
              label: l10n.create,
              icon: Icons.add,
              onPressed: onCreateSpace,
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= AppBreakpoints.medium ? 3 : 1;

        return GridView.builder(
          itemCount: spaces.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: AppSizes.md.w,
            mainAxisSpacing: AppSizes.md.h,
            childAspectRatio: columns == 1 ? 3.35 : 2.55,
          ),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final space = spaces[index];
            return SpacePreviewCard(
              title: space.name,
              subtitle: space.description?.isNotEmpty == true
                  ? space.description!
                  : l10n.notesWorkspaceFallback,
              icon: space.icon,
              color: space.color,
              onTap: onOpenNotesForSpace == null
                  ? null
                  : () => onOpenNotesForSpace!(space.id),
            );
          },
        );
      },
    );
  }
}

class _KnowledgePanels extends StatelessWidget {
  const _KnowledgePanels({
    required this.summary,
    required this.onOpenNotes,
    required this.onOpenTasks,
  });

  final DashboardSummary summary;
  final VoidCallback? onOpenNotes;
  final VoidCallback? onOpenTasks;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= AppBreakpoints.medium;
        final panels = [
          RecentItemsPanel(
            title: l10n.recentNotes,
            icon: Icons.history_edu_outlined,
            items: summary.recentNotes,
            onTap: onOpenNotes,
          ),
          RecentItemsPanel(
            title: l10n.recentTasks,
            icon: Icons.task_alt,
            items: summary.recentTasks,
            onTap: onOpenTasks,
          ),
          _StatisticsPanel(summary: summary),
        ];

        if (isWide) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: panels[0]),
              SizedBox(width: AppSizes.md.w),
              Expanded(child: panels[1]),
              SizedBox(width: AppSizes.md.w),
              Expanded(child: panels[2]),
            ],
          );
        }

        return Column(
          children: [
            panels[0],
            SizedBox(height: AppSizes.md.h),
            panels[1],
            SizedBox(height: AppSizes.md.h),
            panels[2],
          ],
        );
      },
    );
  }
}

class _StatisticsPanel extends StatelessWidget {
  const _StatisticsPanel({required this.summary});

  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.insights_outlined),
              SizedBox(width: AppSizes.xs.w),
              Expanded(
                child: Text(
                  l10n.statisticsSummary,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppSizes.md.h),
          _StatRow(
            label: l10n.writingStreak,
            value: l10n.dayCount(summary.writingStreak),
          ),
          _StatRow(
            label: l10n.wordsWritten,
            value: summary.totalWordsWritten.toString(),
          ),
          _StatRow(label: l10n.mostActiveSpace, value: summary.mostActiveSpace),
          _StatRow(
            label: l10n.mostUsedTags,
            value: summary.mostUsedTags.isEmpty
                ? l10n.noTagsYet
                : summary.mostUsedTags.join(', '),
          ),
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  const _DashboardError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(AppSizes.lg.w),
        child: AppCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56.w,
                height: 56.w,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                ),
                child: const Icon(
                  Icons.cloud_off_outlined,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: AppSizes.md.h),
              Text(
                l10n.dashboardLoadFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSizes.xs.h),
              Text(
                l10n.dashboardDataLoadFailed,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              SizedBox(height: AppSizes.lg.h),
              AppButton(
                label: l10n.retry,
                icon: Icons.refresh,
                onPressed: () => context.read<DashboardCubit>().load(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: AppSizes.sm.h),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
        ),
        TextButton.icon(
          onPressed: onAction,
          icon: const Icon(Icons.arrow_forward),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}
