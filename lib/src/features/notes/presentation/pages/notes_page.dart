import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/domain/visibility_level.dart';
import '../../../../core/localization/l10n_extensions.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/animated_entry.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_card.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../spaces/domain/entities/space.dart';
import '../../domain/entities/note.dart';
import '../cubit/notes_cubit.dart';
import '../cubit/notes_state.dart';

class NotesPage extends StatelessWidget {
  const NotesPage({this.initialSpaceId, super.key});

  final String? initialSpaceId;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<NotesCubit>()..load(spaceId: initialSpaceId),
      child: const _NotesView(),
    );
  }
}

class _NotesView extends StatelessWidget {
  const _NotesView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateNoteSheet(context),
        icon: const Icon(Icons.add),
        label: Text(context.l10n.createNote),
      ),
      body: SafeArea(
        child: ResponsivePage(
          child: RefreshIndicator(
            onRefresh: () {
              final state = context.read<NotesCubit>().state;
              final spaceId = state is NotesLoaded
                  ? state.selectedSpaceId
                  : null;
              return context.read<NotesCubit>().load(spaceId: spaceId);
            },
            child: CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(20.w, 18.h, 20.w, 0),
                  sliver: SliverToBoxAdapter(
                    child: _Header(
                      onCreate: () => _showCreateNoteSheet(context),
                    ),
                  ),
                ),
                SliverPadding(
                  padding: EdgeInsets.all(20.w),
                  sliver: BlocBuilder<NotesCubit, NotesState>(
                    builder: (context, state) {
                      if (state is NotesLoading || state is NotesInitial) {
                        return const SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      if (state is NotesFailure) {
                        return SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Text(context.l10n.notesLoadFailed),
                          ),
                        );
                      }

                      final loaded = state as NotesLoaded;
                      final selectedSpace = _selectedSpace(loaded);

                      return SliverList.list(
                        children: [
                          if (loaded.spaces.isNotEmpty)
                            _SpaceContextBar(
                              spaces: loaded.spaces,
                              selectedSpaceId: loaded.selectedSpaceId,
                              onChanged: (spaceId) => context
                                  .read<NotesCubit>()
                                  .load(spaceId: spaceId),
                            ),
                          SizedBox(height: AppSizes.md.h),
                          _NotesSummary(
                            count: loaded.notes.length,
                            spaceName: selectedSpace?.name,
                          ),
                          SizedBox(height: AppSizes.lg.h),
                          if (loaded.spaces.isEmpty)
                            _EmptyNotes(
                              message: context.l10n.notesNeedSpaceLong,
                              icon: Icons.space_dashboard_outlined,
                            )
                          else if (loaded.notes.isEmpty)
                            _EmptyNotes(
                              message: context.l10n.notesEmptyInSpace,
                              icon: Icons.notes_outlined,
                            )
                          else
                            for (
                              var index = 0;
                              index < loaded.notes.length;
                              index++
                            )
                              Padding(
                                padding: EdgeInsets.only(bottom: AppSizes.md.h),
                                child: AnimatedEntry(
                                  index: index,
                                  child: _NoteCard(
                                    note: loaded.notes[index],
                                    onOpen: () => _openNoteDetail(
                                      context,
                                      loaded.notes[index],
                                    ),
                                    onFavorite: () =>
                                        context.read<NotesCubit>().favorite(
                                          loaded.notes[index].id,
                                          !loaded.notes[index].isFavorite,
                                        ),
                                    onArchive: () => context
                                        .read<NotesCubit>()
                                        .archive(loaded.notes[index].id),
                                    onDelete: () => context
                                        .read<NotesCubit>()
                                        .delete(loaded.notes[index].id),
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

  Space? _selectedSpace(NotesLoaded loaded) {
    for (final space in loaded.spaces) {
      if (space.id == loaded.selectedSpaceId) {
        return space;
      }
    }
    return null;
  }

  void _showCreateNoteSheet(BuildContext context) {
    final state = context.read<NotesCubit>().state;

    if (state is NotesLoaded && state.spaces.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.notesNeedSpace)));
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: context.read<NotesCubit>(),
        child: const _CreateNoteSheet(),
      ),
    );
  }

  void _openNoteDetail(BuildContext context, Note note) {
    Navigator.of(context).push(
      PageRouteBuilder<void>(
        pageBuilder: (_, animation, _) => BlocProvider.value(
          value: context.read<NotesCubit>(),
          child: _NoteDetailPage(note: note),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.notes,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: AppSizes.xs.h),
              Text(
                l10n.notesSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: AppSizes.md.w),
        AppButton(label: l10n.create, icon: Icons.add, onPressed: onCreate),
      ],
    );
  }
}

class _SpaceContextBar extends StatelessWidget {
  const _SpaceContextBar({
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
                      Icon(space.icon, color: space.color, size: 20),
                      SizedBox(width: AppSizes.sm.w),
                      Expanded(
                        child: Text(
                          space.name,
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

class _NotesSummary extends StatelessWidget {
  const _NotesSummary({required this.count, required this.spaceName});

  final int count;
  final String? spaceName;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return AppCard(
      color: Theme.of(
        context,
      ).colorScheme.secondaryContainer.withValues(alpha: 0.32),
      child: Row(
        children: [
          Container(
            width: 48.w,
            height: 48.w,
            decoration: BoxDecoration(
              color: AppColors.blue.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppSizes.radiusSm.r),
            ),
            child: const Icon(Icons.notes_outlined, color: AppColors.blue),
          ),
          SizedBox(width: AppSizes.md.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.noteCount(count),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: AppSizes.xxs.h),
                Text(
                  spaceName == null
                      ? l10n.noSpaceSelected
                      : l10n.inSpace(spaceName!),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
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

class _NoteCard extends StatelessWidget {
  const _NoteCard({
    required this.note,
    required this.onOpen,
    required this.onFavorite,
    required this.onArchive,
    required this.onDelete,
  });

  final Note note;
  final VoidCallback onOpen;
  final VoidCallback onFavorite;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = context.l10n;

    return Hero(
      tag: 'note-card-${note.id}',
      child: Material(
        color: Colors.transparent,
        child: AppCard(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      note.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  _VisibilityBadge(visibility: note.visibility),
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
                          note.isFavorite
                              ? l10n.removeFromFavorites
                              : l10n.addToFavorites,
                        ),
                      ),
                      PopupMenuItem(
                        value: 'archive',
                        child: Text(l10n.archive),
                      ),
                      PopupMenuItem(value: 'delete', child: Text(l10n.trash)),
                    ],
                  ),
                ],
              ),
              SizedBox(height: AppSizes.sm.h),
              Text(
                note.richText.isEmpty ? l10n.contentMissing : note.richText,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NoteDetailPage extends StatelessWidget {
  const _NoteDetailPage({required this.note});

  final Note note;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

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
                          l10n.noteDetails,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: note.isFavorite
                            ? l10n.removeFromFavorites
                            : l10n.addToFavorites,
                        icon: Icon(
                          note.isFavorite ? Icons.star : Icons.star_border,
                        ),
                        onPressed: () async {
                          await context.read<NotesCubit>().favorite(
                            note.id,
                            !note.isFavorite,
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
                          await context.read<NotesCubit>().archive(note.id);
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                      IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () async {
                          await context.read<NotesCubit>().delete(note.id);
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
                    tag: 'note-card-${note.id}',
                    child: Material(
                      color: Colors.transparent,
                      child: AppCard(
                        color: note.backgroundColor,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _VisibilityBadge(visibility: note.visibility),
                            SizedBox(height: AppSizes.md.h),
                            Text(
                              note.title,
                              style: theme.textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            SizedBox(height: AppSizes.lg.h),
                            Text(
                              note.richText.isEmpty
                                  ? l10n.contentMissing
                                  : note.richText,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                height: 1.65,
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
}

class _VisibilityBadge extends StatelessWidget {
  const _VisibilityBadge({required this.visibility});

  final VisibilityLevel visibility;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final (label, icon) = switch (visibility) {
      VisibilityLevel.private => (l10n.privateVisibility, Icons.lock_outline),
      VisibilityLevel.friends => (l10n.friendsVisibility, Icons.group_outlined),
      VisibilityLevel.public => (l10n.publicVisibility, Icons.public),
    };

    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
      backgroundColor: AppColors.primary.withValues(alpha: 0.1),
    );
  }
}

class _EmptyNotes extends StatelessWidget {
  const _EmptyNotes({required this.message, required this.icon});

  final String message;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 80.h),
      child: Column(
        children: [
          Icon(icon, size: 56.sp, color: AppColors.primary),
          SizedBox(height: AppSizes.md.h),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _CreateNoteSheet extends StatefulWidget {
  const _CreateNoteSheet();

  @override
  State<_CreateNoteSheet> createState() => _CreateNoteSheetState();
}

class _CreateNoteSheetState extends State<_CreateNoteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String? _spaceId;
  VisibilityLevel _visibility = VisibilityLevel.private;

  @override
  void initState() {
    super.initState();
    final state = context.read<NotesCubit>().state;
    if (state is NotesLoaded) {
      _spaceId = state.selectedSpaceId;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false) || _spaceId == null) {
      return;
    }

    await context.read<NotesCubit>().create(
      spaceId: _spaceId!,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      visibility: _visibility,
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NotesCubit>().state;
    final spaces = state is NotesLoaded ? state.spaces : <Space>[];
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
                l10n.createNote,
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
                minLines: 4,
                maxLines: 8,
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
