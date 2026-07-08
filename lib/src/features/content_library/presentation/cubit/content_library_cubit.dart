import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/entity_status.dart';
import '../../../articles/domain/entities/article.dart';
import '../../../articles/domain/repositories/articles_repository.dart';
import '../../../notes/domain/entities/note.dart';
import '../../../notes/domain/repositories/notes_repository.dart';
import '../../../tasks/domain/entities/task_item.dart';
import '../../../tasks/domain/repositories/tasks_repository.dart';
import '../../domain/entities/content_library_item.dart';
import 'content_library_state.dart';

class ContentLibraryCubit extends Cubit<ContentLibraryState> {
  ContentLibraryCubit(
    this._notesRepository,
    this._tasksRepository,
    this._articlesRepository,
  ) : super(const ContentLibraryInitial());

  final NotesRepository _notesRepository;
  final TasksRepository _tasksRepository;
  final ArticlesRepository _articlesRepository;

  ContentLibraryMode? _mode;

  Future<void> load(ContentLibraryMode mode) async {
    _mode = mode;
    emit(const ContentLibraryLoading());

    try {
      final status = switch (mode) {
        ContentLibraryMode.archive => EntityStatus.archived,
        ContentLibraryMode.trash => EntityStatus.trashed,
        ContentLibraryMode.favorites => null,
      };
      final favoritesOnly = mode == ContentLibraryMode.favorites;

      final results = await Future.wait([
        _notesRepository.getNotes(
          status: status,
          favoritesOnly: favoritesOnly,
          limit: 100,
        ),
        _tasksRepository.getTasks(
          status: status,
          favoritesOnly: favoritesOnly,
          limit: 100,
        ),
        _articlesRepository.getArticles(
          status: status,
          favoritesOnly: favoritesOnly,
          limit: 100,
        ),
      ]);

      final items = <ContentLibraryItem>[
        ...(results[0] as List<Note>).map(_noteItem),
        ...(results[1] as List<TaskItem>).map(_taskItem),
        ...(results[2] as List<Article>).map(_articleItem),
      ]..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));

      emit(ContentLibraryLoaded(mode: mode, items: items));
    } catch (_) {
      emit(const ContentLibraryFailure('İçerik yüklenemedi.'));
    }
  }

  Future<void> favorite(ContentLibraryItem item, bool isFavorite) async {
    await _perform(() {
      return switch (item.type) {
        ContentLibraryItemType.note => _notesRepository.favoriteNote(
          item.id,
          isFavorite: isFavorite,
        ),
        ContentLibraryItemType.task => _tasksRepository.favoriteTask(
          item.id,
          isFavorite: isFavorite,
        ),
        ContentLibraryItemType.article => _articlesRepository.favoriteArticle(
          item.id,
          isFavorite: isFavorite,
        ),
      };
    });
  }

  Future<void> archive(ContentLibraryItem item) async {
    await _perform(() {
      return switch (item.type) {
        ContentLibraryItemType.note => _notesRepository.archiveNote(item.id),
        ContentLibraryItemType.task => _tasksRepository.archiveTask(item.id),
        ContentLibraryItemType.article => _articlesRepository.archiveArticle(
          item.id,
        ),
      };
    });
  }

  Future<void> trash(ContentLibraryItem item) async {
    await _perform(() {
      return switch (item.type) {
        ContentLibraryItemType.note => _notesRepository.trashNote(item.id),
        ContentLibraryItemType.task => _tasksRepository.deleteTask(item.id),
        ContentLibraryItemType.article => _articlesRepository.deleteArticle(
          item.id,
        ),
      };
    });
  }

  Future<void> restore(ContentLibraryItem item) async {
    await _perform(() {
      return switch (item.type) {
        ContentLibraryItemType.note => _notesRepository.restoreNote(item.id),
        ContentLibraryItemType.task => _tasksRepository.restoreTask(item.id),
        ContentLibraryItemType.article => _articlesRepository.restoreArticle(
          item.id,
        ),
      };
    });
  }

  Future<void> _perform(Future<void> Function() action) async {
    final mode = _mode;
    if (mode == null) {
      return;
    }

    try {
      await action();
      await load(mode);
    } catch (_) {
      emit(const ContentLibraryFailure('İşlem tamamlanamadı.'));
    }
  }

  ContentLibraryItem _noteItem(Note note) {
    return ContentLibraryItem(
      id: note.id,
      title: note.title,
      subtitle: note.richText,
      type: ContentLibraryItemType.note,
      status: note.status,
      isFavorite: note.isFavorite,
      updatedAt: note.updatedAt,
    );
  }

  ContentLibraryItem _taskItem(TaskItem task) {
    return ContentLibraryItem(
      id: task.id,
      title: task.title,
      subtitle: task.description ?? '',
      type: ContentLibraryItemType.task,
      status: task.status,
      isFavorite: task.isFavorite,
      updatedAt: task.updatedAt,
    );
  }

  ContentLibraryItem _articleItem(Article article) {
    return ContentLibraryItem(
      id: article.id,
      title: article.title,
      subtitle: article.richText,
      type: ContentLibraryItemType.article,
      status: article.status,
      isFavorite: article.isFavorite,
      updatedAt: article.updatedAt,
      coverImageUrl: article.coverImageUrl,
    );
  }
}
