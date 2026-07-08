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
import '../../domain/entities/space.dart';
import '../cubit/spaces_cubit.dart';
import '../cubit/spaces_state.dart';
import '../widgets/space_form_sheet.dart';

class SpacesPage extends StatelessWidget {
  const SpacesPage({this.onOpenNotesForSpace, super.key});

  final ValueChanged<String>? onOpenNotesForSpace;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<SpacesCubit>()..load(),
      child: _SpacesView(onOpenNotesForSpace: onOpenNotesForSpace),
    );
  }
}

class _SpacesView extends StatelessWidget {
  const _SpacesView({required this.onOpenNotesForSpace});

  final ValueChanged<String>? onOpenNotesForSpace;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showSpaceFormSheet(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createSpace),
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: RefreshIndicator(
            onRefresh: () => context.read<SpacesCubit>().load(),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: _Header(onCreate: () => showSpaceFormSheet(context)),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                  sliver: BlocBuilder<SpacesCubit, SpacesState>(
                    builder: (context, state) {
                      if (state is SpacesLoading || state is SpacesInitial) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is SpacesFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _ErrorState(),
                        );
                      }

                      final spaces = (state as SpacesLoaded).spaces;
                      if (spaces.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptySpaces(
                            onCreate: () => showSpaceFormSheet(context),
                          ),
                        );
                      }

                      return SliverList.list(
                        children: [
                          _SpacesSummary(spaces: spaces),
                          SizedBox(height: AppSizes.lg.h),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final columns =
                                  constraints.maxWidth >= AppBreakpoints.medium
                                  ? 2
                                  : 1;

                              return GridView.builder(
                                itemCount: spaces.length,
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: columns,
                                      crossAxisSpacing: AppSizes.md.w,
                                      mainAxisSpacing: AppSizes.md.h,
                                      mainAxisExtent: columns == 1
                                          ? 166.h
                                          : 178.h,
                                    ),
                                itemBuilder: (context, index) {
                                  final space = spaces[index];
                                  return _SpaceCard(
                                    space: space,
                                    onOpenNotes: onOpenNotesForSpace == null
                                        ? null
                                        : () => onOpenNotesForSpace!(space.id),
                                    onEdit: () => showSpaceFormSheet(
                                      context,
                                      space: space,
                                    ),
                                    onDelete: () =>
                                        _confirmDelete(context, space),
                                  );
                                },
                              );
                            },
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

  Future<void> _confirmDelete(BuildContext context, Space space) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(context.l10n.deleteSpaceQuestion),
        content: Text(context.l10n.deleteSpaceContent(space.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(context.l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(context.l10n.delete),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<SpacesCubit>().delete(space.id);
    }
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 360.w;

        final title = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.spaces,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: AppSizes.xs.h),
            Text(
              l10n.spacesSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.slate,
                height: 1.35,
              ),
            ),
          ],
        );

        final button = AppButton(
          label: l10n.create,
          icon: Icons.add,
          onPressed: onCreate,
        );

        if (compact) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              title,
              SizedBox(height: AppSizes.md.h),
              button,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: title),
            SizedBox(width: AppSizes.md.w),
            ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 150.w),
              child: button,
            ),
          ],
        );
      },
    );
  }
}

class _SpacesSummary extends StatelessWidget {
  const _SpacesSummary({required this.spaces});

  final List<Space> spaces;

  @override
  Widget build(BuildContext context) {
    final pinned = spaces.where((space) => space.isPinned).length;
    final favorites = spaces.where((space) => space.isFavorite).length;
    final l10n = context.l10n;

    return AppCard(
      color: AppColors.softBlue,
      child: Row(
        children: [
          Container(
            width: 52.w,
            height: 52.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            ),
            child: const Icon(
              Icons.space_dashboard_outlined,
              color: AppColors.primary,
            ),
          ),
          SizedBox(width: AppSizes.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.activeSpacesCount(spaces.length),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSizes.xxs.h),
                Text(
                  l10n.pinnedFavoriteSpaces(pinned, favorites),
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.slate),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SpaceCard extends StatelessWidget {
  const _SpaceCard({
    required this.space,
    required this.onEdit,
    required this.onDelete,
    this.onOpenNotes,
  });

  final Space space;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onOpenNotes;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return AppCard(
      onTap: onOpenNotes,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44.w,
                height: 44.w,
                decoration: BoxDecoration(
                  color: space.color.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                ),
                child: Icon(space.icon, color: space.color),
              ),
              SizedBox(width: AppSizes.md.w),
              Expanded(
                child: Text(
                  space.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              PopupMenuButton<String>(
                tooltip: l10n.operations,
                onSelected: (value) {
                  if (value == 'edit') {
                    onEdit();
                  }
                  if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(value: 'edit', child: Text(l10n.edit)),
                  PopupMenuItem(value: 'delete', child: Text(l10n.delete)),
                ],
              ),
            ],
          ),
          SizedBox(height: AppSizes.sm.h),
          Text(
            space.description?.isNotEmpty == true
                ? space.description!
                : l10n.spaceNoDescription,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodySmall?.copyWith(color: AppColors.slate),
          ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: FilledButton.tonalIcon(
              onPressed: onOpenNotes,
              icon: const Icon(Icons.notes_outlined),
              label: Text(l10n.openNotes),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptySpaces extends StatelessWidget {
  const _EmptySpaces({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.space_dashboard_outlined,
          size: 56.sp,
          color: AppColors.primary,
        ),
        SizedBox(height: AppSizes.md.h),
        Text(
          l10n.emptySpacesTitle,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
        ),
        SizedBox(height: AppSizes.xs.h),
        Text(
          l10n.emptySpacesSubtitle,
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
        ),
        SizedBox(height: AppSizes.md.h),
        AppButton(
          label: l10n.createFirstSpace,
          icon: Icons.add,
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(context.l10n.spacesLoadFailed, textAlign: TextAlign.center),
    );
  }
}
