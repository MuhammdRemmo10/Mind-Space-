import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_entry.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../spaces/domain/entities/space.dart';
import '../../domain/entities/article.dart';
import '../cubit/articles_cubit.dart';
import '../cubit/articles_state.dart';

class ArticlesPage extends StatelessWidget {
  const ArticlesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ArticlesCubit>()..load(),
      child: const _ArticlesView(),
    );
  }
}

class _ArticlesView extends StatelessWidget {
  const _ArticlesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateArticleSheet(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createArticle),
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: RefreshIndicator(
            onRefresh: () {
              final state = context.read<ArticlesCubit>().state;
              final spaceId = state is ArticlesLoaded
                  ? state.selectedSpaceId
                  : null;
              return context.read<ArticlesCubit>().load(spaceId: spaceId);
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      onCreate: () => _showCreateArticleSheet(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 120.h),
                  sliver: BlocBuilder<ArticlesCubit, ArticlesState>(
                    builder: (context, state) {
                      if (state is ArticlesLoading ||
                          state is ArticlesInitial) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is ArticlesFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(context.l10n.articlesLoadFailed),
                          ),
                        );
                      }

                      final loaded = state as ArticlesLoaded;
                      final selectedSpace = _selectedSpace(loaded);
                      final draftCount = loaded.articles
                          .where(
                            (article) => article.status == EntityStatus.draft,
                          )
                          .length;
                      final publishedCount =
                          loaded.articles.length - draftCount;

                      return SliverList.list(
                        children: [
                          if (loaded.spaces.isNotEmpty)
                            _SpaceFilter(
                              spaces: loaded.spaces,
                              selectedSpaceId: loaded.selectedSpaceId,
                              onChanged: (spaceId) => context
                                  .read<ArticlesCubit>()
                                  .load(spaceId: spaceId),
                            ),
                          SizedBox(height: AppSizes.md.h),
                          _ArticleStatsCard(
                            total: loaded.articles.length,
                            drafts: draftCount,
                            published: publishedCount,
                            spaceName: selectedSpace?.name,
                          ),
                          SizedBox(height: AppSizes.lg.h),
                          if (loaded.spaces.isEmpty)
                            _EmptyArticles(
                              title: context.l10n.articlesNeedSpace,
                              subtitle: context.l10n.articlesNeedSpaceLong,
                              onCreate: () => _showCreateArticleSheet(context),
                            )
                          else if (loaded.articles.isEmpty)
                            _EmptyArticles(
                              title: context.l10n.articlesEmpty,
                              subtitle: context.l10n.articlesEmptySubtitle,
                              onCreate: () => _showCreateArticleSheet(context),
                            )
                          else
                            _ArticlesGrid(
                              articles: loaded.articles,
                              spaces: loaded.spaces,
                              onOpen: (article) =>
                                  _openArticleDetail(context, article),
                              onPublish: (article) =>
                                  context.read<ArticlesCubit>().publish(
                                    article.id,
                                    visibility: article.visibility,
                                  ),
                              onFavorite: (article) => context
                                  .read<ArticlesCubit>()
                                  .favorite(article.id, !article.isFavorite),
                              onArchive: (article) => context
                                  .read<ArticlesCubit>()
                                  .archive(article.id),
                              onDelete: (article) => context
                                  .read<ArticlesCubit>()
                                  .delete(article.id),
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

  Space? _selectedSpace(ArticlesLoaded loaded) {
    for (final space in loaded.spaces) {
      if (space.id == loaded.selectedSpaceId) {
        return space;
      }
    }
    return null;
  }

  void _showCreateArticleSheet(BuildContext context) {
    final state = context.read<ArticlesCubit>().state;
    if (state is ArticlesLoaded && state.spaces.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.articlesNeedSpace)));
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<ArticlesCubit>(),
        child: const _CreateArticleSheet(),
      ),
    );
  }

  void _openArticleDetail(BuildContext context, Article article) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, _) => BlocProvider.value(
          value: context.read<ArticlesCubit>(),
          child: ArticleDetailPage(article: article),
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
  const _Header({required this.onCreate});

  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: AppSizes.md.w,
      runSpacing: AppSizes.md.h,
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 620.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.articles,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSizes.xs.h),
              Text(
                l10n.articlesSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        AppButton(
          label: l10n.createArticle,
          icon: Icons.add,
          onPressed: onCreate,
        ),
      ],
    );
  }
}

class _SpaceFilter extends StatelessWidget {
  const _SpaceFilter({
    required this.spaces,
    required this.selectedSpaceId,
    required this.onChanged,
  });

  final List<Space> spaces;
  final String? selectedSpaceId;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: selectedSpaceId,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          items: spaces
              .map(
                (space) => DropdownMenuItem<String>(
                  value: space.id,
                  child: Row(
                    children: [
                      Icon(space.icon, color: space.color, size: 20.sp),
                      SizedBox(width: AppSizes.sm.w),
                      Expanded(
                        child: Text(
                          space.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
          onChanged: (value) {
            if (value != null) {
              onChanged(value);
            }
          },
        ),
      ),
    );
  }
}

class _ArticleStatsCard extends StatelessWidget {
  const _ArticleStatsCard({
    required this.total,
    required this.drafts,
    required this.published,
    required this.spaceName,
  });

  final int total;
  final int drafts;
  final int published;
  final String? spaceName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return AppCard(
      color: AppColors.softBlue.withValues(alpha: 0.68),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            ),
            child: Icon(
              Icons.article_outlined,
              color: AppColors.primary,
              size: 26.sp,
            ),
          ),
          SizedBox(width: AppSizes.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.articleCountSummary(total),
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSizes.xxs.h),
                Text(
                  spaceName == null
                      ? l10n.noSpaceSelected
                      : l10n.inSpace(spaceName!),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: AppSizes.sm.w),
          _TinyMetric(label: l10n.drafts, value: drafts.toString()),
          SizedBox(width: AppSizes.xs.w),
          _TinyMetric(label: l10n.published, value: published.toString()),
        ],
      ),
    );
  }
}

class _TinyMetric extends StatelessWidget {
  const _TinyMetric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(minWidth: 56.w),
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.primary,
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _ArticlesGrid extends StatelessWidget {
  const _ArticlesGrid({
    required this.articles,
    required this.spaces,
    required this.onOpen,
    required this.onPublish,
    required this.onFavorite,
    required this.onArchive,
    required this.onDelete,
  });

  final List<Article> articles;
  final List<Space> spaces;
  final ValueChanged<Article> onOpen;
  final ValueChanged<Article> onPublish;
  final ValueChanged<Article> onFavorite;
  final ValueChanged<Article> onArchive;
  final ValueChanged<Article> onDelete;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final spacing = AppSizes.md.w;
        final columns = constraints.maxWidth >= 840 ? 2 : 1;
        final itemWidth = columns == 1
            ? constraints.maxWidth
            : (constraints.maxWidth - spacing) / columns;

        return Wrap(
          spacing: spacing,
          runSpacing: AppSizes.md.h,
          children: [
            for (var index = 0; index < articles.length; index++)
              SizedBox(
                width: itemWidth,
                child: AnimatedEntry(
                  index: index,
                  child: _ArticleCard(
                    article: articles[index],
                    spaceName: _spaceName(articles[index]),
                    onOpen: () => onOpen(articles[index]),
                    onPublish: () => onPublish(articles[index]),
                    onFavorite: () => onFavorite(articles[index]),
                    onArchive: () => onArchive(articles[index]),
                    onDelete: () => onDelete(articles[index]),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }

  String? _spaceName(Article article) {
    for (final space in spaces) {
      if (space.id == article.spaceId) {
        return space.name;
      }
    }
    return null;
  }
}

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({
    required this.article,
    required this.spaceName,
    required this.onOpen,
    required this.onPublish,
    required this.onFavorite,
    required this.onArchive,
    required this.onDelete,
  });

  final Article article;
  final String? spaceName;
  final VoidCallback onOpen;
  final VoidCallback onPublish;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDraft = article.status == EntityStatus.draft;

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'article-cover-${article.id}',
            child: _ArticleCover(article: article, height: 154.h),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        article.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    PopupMenuButton<String>(
                      tooltip: l10n.more,
                      icon: const Icon(Icons.more_horiz),
                      onSelected: (value) {
                        if (value == 'favorite') {
                          onFavorite();
                        }
                        if (value == 'archive') {
                          onArchive();
                        }
                        if (value == 'delete') {
                          onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'favorite',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: Icon(
                              article.isFavorite
                                  ? Icons.star
                                  : Icons.star_border,
                            ),
                            title: Text(
                              article.isFavorite
                                  ? l10n.removeFromFavorites
                                  : l10n.addToFavorites,
                            ),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'archive',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.archive_outlined),
                            title: Text(l10n.archive),
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            leading: const Icon(Icons.delete_outline),
                            title: Text(l10n.trash),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.xs.h),
                Text(
                  article.richText.isEmpty
                      ? l10n.contentMissing
                      : article.richText,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
                  ),
                ),
                SizedBox(height: AppSizes.md.h),
                Wrap(
                  spacing: AppSizes.xs.w,
                  runSpacing: AppSizes.xs.h,
                  children: [
                    _StatusChip(
                      label: isDraft ? l10n.draft : l10n.published,
                      icon: isDraft
                          ? Icons.edit_note_outlined
                          : Icons.verified_outlined,
                      color: isDraft ? AppColors.amber : AppColors.mint,
                    ),
                    _VisibilityChip(visibility: article.visibility),
                    _StatusChip(
                      label: l10n.articleReadingMinutes(
                        article.readingTimeMinutes == 0
                            ? 1
                            : article.readingTimeMinutes,
                      ),
                      icon: Icons.schedule,
                      color: AppColors.blue,
                    ),
                    if (spaceName != null)
                      _StatusChip(
                        label: spaceName!,
                        icon: Icons.space_dashboard_outlined,
                        color: AppColors.violet,
                      ),
                  ],
                ),
                if (isDraft) ...[
                  SizedBox(height: AppSizes.md.h),
                  SizedBox(
                    width: double.infinity,
                    child: AppButton(
                      label: l10n.publishArticle,
                      icon: Icons.publish_outlined,
                      style: AppButtonStyle.tonal,
                      onPressed: onPublish,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ArticleCover extends StatelessWidget {
  const _ArticleCover({required this.article, required this.height});

  final Article article;
  final double height;

  @override
  Widget build(BuildContext context) {
    final imageUrl = article.coverImageUrl;

    return ClipRRect(
      borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: imageUrl == null || imageUrl.isEmpty
            ? const _CoverFallback()
            : Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    const _CoverFallback(),
              ),
      ),
    );
  }
}

class _CoverFallback extends StatelessWidget {
  const _CoverFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.secondary],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.auto_stories_outlined,
          color: Colors.white,
          size: 42.sp,
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15.sp),
          SizedBox(width: 5.w),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityChip extends StatelessWidget {
  const _VisibilityChip({required this.visibility});

  final VisibilityLevel visibility;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, icon, color) = switch (visibility) {
      VisibilityLevel.private => (
        l10n.privateVisibility,
        Icons.lock_outline,
        AppColors.ink,
      ),
      VisibilityLevel.friends => (
        l10n.friendsVisibility,
        Icons.group_outlined,
        AppColors.violet,
      ),
      VisibilityLevel.public => (
        l10n.publicVisibility,
        Icons.public,
        AppColors.mint,
      ),
    };

    return _StatusChip(label: label, icon: icon, color: color);
  }
}

class _EmptyArticles extends StatelessWidget {
  const _EmptyArticles({
    required this.title,
    required this.subtitle,
    required this.onCreate,
  });

  final String title;
  final String subtitle;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return AnimatedEntry(
      child: AppCard(
        child: Column(
          children: [
            Icon(Icons.article_outlined, size: 54.sp, color: AppColors.primary),
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
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            SizedBox(height: AppSizes.md.h),
            AppButton(
              label: context.l10n.createArticle,
              icon: Icons.add,
              onPressed: onCreate,
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateArticleSheet extends StatefulWidget {
  const _CreateArticleSheet();

  @override
  State<_CreateArticleSheet> createState() => _CreateArticleSheetState();
}

class _CreateArticleSheetState extends State<_CreateArticleSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _spaceId;
  String? _coverImagePath;
  VisibilityLevel _visibility = VisibilityLevel.private;
  bool _publishNow = false;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final state = context.read<ArticlesCubit>().state;
    if (state is ArticlesLoaded) {
      _spaceId =
          state.selectedSpaceId ??
          (state.spaces.isNotEmpty ? state.spaces.first.id : null);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickCover() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 86,
      maxWidth: 1800,
    );

    if (picked != null && mounted) {
      setState(() => _coverImagePath = picked.path);
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _spaceId == null) {
      return;
    }

    setState(() => _isSaving = true);
    await context.read<ArticlesCubit>().create(
      spaceId: _spaceId!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      visibility: _visibility,
      coverImagePath: _coverImagePath,
      publishNow: _publishNow,
    );

    if (mounted) {
      setState(() => _isSaving = false);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<ArticlesCubit>().state;
    final spaces = state is ArticlesLoaded ? state.spaces : <Space>[];
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
                l10n.createArticle,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
              ),
              SizedBox(height: AppSizes.md.h),
              DropdownButtonFormField<String>(
                initialValue: _spaceId,
                decoration: InputDecoration(
                  labelText: l10n.space,
                  prefixIcon: const Icon(Icons.space_dashboard_outlined),
                ),
                items: spaces
                    .map(
                      (space) => DropdownMenuItem<String>(
                        value: space.id,
                        child: Text(space.name),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _spaceId = value),
                validator: (value) => value == null ? l10n.spaceRequired : null,
              ),
              SizedBox(height: AppSizes.md.h),
              InkWell(
                onTap: _pickCover,
                borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                child: Container(
                  height: 150.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.softBlue,
                    borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
                    border: Border.all(color: Theme.of(context).dividerColor),
                  ),
                  child: _coverImagePath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_photo_alternate_outlined,
                              color: AppColors.primary,
                              size: 32.sp,
                            ),
                            SizedBox(height: AppSizes.xs.h),
                            Text(
                              l10n.selectCoverImage,
                              style: Theme.of(context).textTheme.labelLarge
                                  ?.copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.w900,
                                  ),
                            ),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(
                                AppSizes.radiusSm.r,
                              ),
                              child: Image.file(
                                File(_coverImagePath!),
                                fit: BoxFit.cover,
                              ),
                            ),
                            Positioned(
                              right: 10.w,
                              bottom: 10.h,
                              child: FilledButton.tonalIcon(
                                onPressed: _pickCover,
                                icon: const Icon(Icons.swap_horiz),
                                label: Text(l10n.changeCoverImage),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _titleController,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  labelText: l10n.title,
                  prefixIcon: const Icon(Icons.title),
                ),
                validator: (value) =>
                    (value?.trim().isEmpty ?? true) ? l10n.titleRequired : null,
              ),
              SizedBox(height: AppSizes.md.h),
              TextFormField(
                controller: _contentController,
                decoration: InputDecoration(
                  labelText: l10n.content,
                  prefixIcon: const Icon(Icons.edit_note),
                ),
                minLines: 7,
                maxLines: 14,
                validator: (value) => (value?.trim().isEmpty ?? true)
                    ? l10n.articleContentRequired
                    : null,
              ),
              SizedBox(height: AppSizes.md.h),
              SegmentedButton<VisibilityLevel>(
                segments: [
                  ButtonSegment(
                    value: VisibilityLevel.private,
                    label: Text(l10n.privateVisibility),
                    icon: const Icon(Icons.lock_outline),
                  ),
                  ButtonSegment(
                    value: VisibilityLevel.friends,
                    label: Text(l10n.friendVisibilityShort),
                    icon: const Icon(Icons.group_outlined),
                  ),
                  ButtonSegment(
                    value: VisibilityLevel.public,
                    label: Text(l10n.publicVisibilityShort),
                    icon: const Icon(Icons.public),
                  ),
                ],
                selected: {_visibility},
                onSelectionChanged: (value) =>
                    setState(() => _visibility = value.first),
              ),
              SizedBox(height: AppSizes.sm.h),
              SwitchListTile.adaptive(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.publishNow),
                subtitle: Text(l10n.publishNowSubtitle),
                value: _publishNow,
                onChanged: (value) => setState(() => _publishNow = value),
              ),
              SizedBox(height: AppSizes.lg.h),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: _publishNow ? l10n.publishArticle : l10n.save,
                  icon: _publishNow ? Icons.publish_outlined : Icons.check,
                  isLoading: _isSaving,
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

class ArticleDetailPage extends StatelessWidget {
  const ArticleDetailPage({required this.article, super.key});

  final Article article;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDraft = article.status == EntityStatus.draft;

    return Scaffold(
      body: SafeArea(
        child: ResponsivePage(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                expandedHeight: 260.h,
                leading: IconButton(
                  tooltip: l10n.back,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                actions: [
                  if (isDraft)
                    IconButton(
                      tooltip: l10n.publishArticle,
                      icon: const Icon(Icons.publish_outlined),
                      onPressed: () async {
                        await context.read<ArticlesCubit>().publish(
                          article.id,
                          visibility: article.visibility,
                        );
                        if (context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  IconButton(
                    tooltip: article.isFavorite
                        ? l10n.removeFromFavorites
                        : l10n.addToFavorites,
                    icon: Icon(
                      article.isFavorite ? Icons.star : Icons.star_border,
                    ),
                    onPressed: () async {
                      await context.read<ArticlesCubit>().favorite(
                        article.id,
                        !article.isFavorite,
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
                      await context.read<ArticlesCubit>().archive(article.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                  IconButton(
                    tooltip: l10n.delete,
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await context.read<ArticlesCubit>().delete(article.id);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Hero(
                    tag: 'article-cover-${article.id}',
                    child: _ArticleCover(article: article, height: 260.h),
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.all(20.w),
                sliver: SliverList.list(
                  children: [
                    AnimatedEntry(
                      child: Wrap(
                        spacing: AppSizes.xs.w,
                        runSpacing: AppSizes.xs.h,
                        children: [
                          _StatusChip(
                            label: isDraft ? l10n.draft : l10n.published,
                            icon: isDraft
                                ? Icons.edit_note_outlined
                                : Icons.verified_outlined,
                            color: isDraft ? AppColors.amber : AppColors.mint,
                          ),
                          _VisibilityChip(visibility: article.visibility),
                          _StatusChip(
                            label: l10n.articleReadingMinutes(
                              article.readingTimeMinutes == 0
                                  ? 1
                                  : article.readingTimeMinutes,
                            ),
                            icon: Icons.schedule,
                            color: AppColors.blue,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: AppSizes.md.h),
                    AnimatedEntry(
                      index: 1,
                      child: Text(
                        article.title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: AppSizes.lg.h),
                    AnimatedEntry(
                      index: 2,
                      child: Text(
                        article.richText.isEmpty
                            ? l10n.contentMissing
                            : article.richText,
                        style: theme.textTheme.bodyLarge?.copyWith(height: 1.7),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
