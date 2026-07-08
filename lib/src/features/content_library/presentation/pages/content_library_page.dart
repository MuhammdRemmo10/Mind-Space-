import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entity_status.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_entry.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/content_library_item.dart';
import '../cubit/content_library_cubit.dart';
import '../cubit/content_library_state.dart';

class ContentLibraryPage extends StatelessWidget {
  const ContentLibraryPage({required this.mode, super.key});

  final ContentLibraryMode mode;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ContentLibraryCubit>()..load(mode),
      child: _ContentLibraryView(mode: mode),
    );
  }
}

class _ContentLibraryView extends StatelessWidget {
  const _ContentLibraryView({required this.mode});

  final ContentLibraryMode mode;

  @override
  Widget build(BuildContext context) {
    final title = _title(context, mode);
    final subtitle = _subtitle(context, mode);

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: RefreshIndicator(
            onRefresh: () => context.read<ContentLibraryCubit>().load(mode),
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: context.l10n.back,
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        SizedBox(width: AppSizes.xs.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.w900),
                              ),
                              SizedBox(height: AppSizes.xs.h),
                              Text(
                                subtitle,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.slate),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 28.h),
                  sliver: BlocBuilder<ContentLibraryCubit, ContentLibraryState>(
                    builder: (context, state) {
                      if (state is ContentLibraryLoading ||
                          state is ContentLibraryInitial) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is ContentLibraryFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(context.l10n.contentLibraryFailed),
                          ),
                        );
                      }

                      final items = (state as ContentLibraryLoaded).items;
                      if (items.isEmpty) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: _EmptyState(mode: mode),
                        );
                      }

                      return SliverToBoxAdapter(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = constraints.maxWidth >= 840 ? 2 : 1;
                            final spacing = AppSizes.md.w;
                            final width = columns == 1
                                ? constraints.maxWidth
                                : (constraints.maxWidth - spacing) / columns;

                            return Wrap(
                              spacing: spacing,
                              runSpacing: AppSizes.md.h,
                              children: [
                                for (
                                  var index = 0;
                                  index < items.length;
                                  index++
                                )
                                  SizedBox(
                                    width: width,
                                    child: AnimatedEntry(
                                      index: index,
                                      child: _ContentItemCard(
                                        item: items[index],
                                        mode: mode,
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
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

  String _title(BuildContext context, ContentLibraryMode mode) {
    return switch (mode) {
      ContentLibraryMode.favorites => context.l10n.favorites,
      ContentLibraryMode.archive => context.l10n.archive,
      ContentLibraryMode.trash => context.l10n.trash,
    };
  }

  String _subtitle(BuildContext context, ContentLibraryMode mode) {
    return switch (mode) {
      ContentLibraryMode.favorites => context.l10n.favoritesSubtitle,
      ContentLibraryMode.archive => context.l10n.archiveSubtitle,
      ContentLibraryMode.trash => context.l10n.trashSubtitle,
    };
  }
}

class _ContentItemCard extends StatelessWidget {
  const _ContentItemCard({required this.item, required this.mode});

  final ContentLibraryItem item;
  final ContentLibraryMode mode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final type = _typeView(context, item.type);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46.w,
                height: 46.w,
                decoration: BoxDecoration(
                  color: type.color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                ),
                child: Icon(type.icon, color: type.color, size: 22.sp),
              ),
              SizedBox(width: AppSizes.sm.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      type.label,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: type.color,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (item.isFavorite)
                const Icon(Icons.star, color: AppColors.amber),
            ],
          ),
          if (item.subtitle.isNotEmpty) ...[
            SizedBox(height: AppSizes.md.h),
            Text(
              item.subtitle,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
          ],
          SizedBox(height: AppSizes.md.h),
          Wrap(
            spacing: AppSizes.xs.w,
            runSpacing: AppSizes.xs.h,
            children: [
              if (mode == ContentLibraryMode.trash ||
                  item.status == EntityStatus.archived)
                AppButton(
                  label: l10n.restore,
                  icon: Icons.restore,
                  style: AppButtonStyle.tonal,
                  onPressed: () =>
                      context.read<ContentLibraryCubit>().restore(item),
                ),
              if (mode != ContentLibraryMode.trash)
                AppButton(
                  label: item.isFavorite
                      ? l10n.removeFromFavorites
                      : l10n.addToFavorites,
                  icon: item.isFavorite ? Icons.star : Icons.star_border,
                  style: AppButtonStyle.tonal,
                  onPressed: () => context.read<ContentLibraryCubit>().favorite(
                    item,
                    !item.isFavorite,
                  ),
                ),
              if (mode != ContentLibraryMode.trash &&
                  item.status != EntityStatus.archived)
                AppButton(
                  label: l10n.archive,
                  icon: Icons.archive_outlined,
                  style: AppButtonStyle.secondary,
                  onPressed: () =>
                      context.read<ContentLibraryCubit>().archive(item),
                ),
              if (mode != ContentLibraryMode.trash)
                AppButton(
                  label: l10n.trash,
                  icon: Icons.delete_outline,
                  style: AppButtonStyle.danger,
                  onPressed: () =>
                      context.read<ContentLibraryCubit>().trash(item),
                ),
            ],
          ),
        ],
      ),
    );
  }

  ({String label, IconData icon, Color color}) _typeView(
    BuildContext context,
    ContentLibraryItemType type,
  ) {
    return switch (type) {
      ContentLibraryItemType.note => (
        label: context.l10n.note,
        icon: Icons.notes_outlined,
        color: AppColors.blue,
      ),
      ContentLibraryItemType.task => (
        label: context.l10n.task,
        icon: Icons.check_circle_outline,
        color: AppColors.mint,
      ),
      ContentLibraryItemType.article => (
        label: context.l10n.article,
        icon: Icons.article_outlined,
        color: AppColors.violet,
      ),
    };
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.mode});

  final ContentLibraryMode mode;

  @override
  Widget build(BuildContext context) {
    final (icon, title, subtitle) = switch (mode) {
      ContentLibraryMode.favorites => (
        Icons.star_border,
        context.l10n.emptyFavoritesTitle,
        context.l10n.emptyFavoritesSubtitle,
      ),
      ContentLibraryMode.archive => (
        Icons.archive_outlined,
        context.l10n.emptyArchiveTitle,
        context.l10n.emptyArchiveSubtitle,
      ),
      ContentLibraryMode.trash => (
        Icons.delete_outline,
        context.l10n.emptyTrashTitle,
        context.l10n.emptyTrashSubtitle,
      ),
    };

    return AppCard(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: AppColors.primary, size: 54.sp),
          SizedBox(height: AppSizes.md.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w900),
          ),
          SizedBox(height: AppSizes.xs.h),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.slate),
          ),
        ],
      ),
    );
  }
}
