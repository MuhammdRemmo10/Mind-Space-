import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/visibility_level.dart';
import '../../../spaces/domain/repositories/spaces_repository.dart';
import '../../domain/entities/article.dart';
import '../../domain/repositories/articles_repository.dart';
import 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  ArticlesCubit(this._articlesRepository, this._spacesRepository)
    : super(const ArticlesInitial());

  final ArticlesRepository _articlesRepository;
  final SpacesRepository _spacesRepository;

  Future<void> load({String? spaceId, bool allSpaces = false}) async {
    emit(const ArticlesLoading());

    try {
      final spaces = await _spacesRepository.getSpaces(limit: 100);
      final selectedSpaceId = allSpaces
          ? null
          : spaceId ?? (spaces.isNotEmpty ? spaces.first.id : null);
      final articles = await _articlesRepository.getArticles(
        spaceId: selectedSpaceId,
        limit: 100,
      );

      emit(
        ArticlesLoaded(
          articles: articles,
          spaces: spaces,
          selectedSpaceId: selectedSpaceId,
          allSpaces: allSpaces,
        ),
      );
    } catch (_) {
      emit(const ArticlesFailure('Makaleler yüklenemedi.'));
    }
  }

  Future<void> create({
    required String spaceId,
    required String title,
    required String content,
    required VisibilityLevel visibility,
    String? coverImagePath,
    bool publishNow = false,
  }) async {
    try {
      await _articlesRepository.createArticle(
        Article(
          id: '',
          spaceId: spaceId,
          title: title,
          richText: content,
          readingTimeMinutes: _readingTime(content),
          visibility: visibility,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
        coverImagePath: coverImagePath,
        publishNow: publishNow,
      );
      await load(spaceId: spaceId);
    } catch (_) {
      emit(const ArticlesFailure('Makale oluşturulamadı.'));
    }
  }

  Future<void> publish(String articleId, {VisibilityLevel? visibility}) async {
    final current = state;
    if (current is! ArticlesLoaded) {
      return;
    }

    try {
      await _articlesRepository.publishArticle(
        articleId,
        visibility: visibility,
      );
      await load(
        spaceId: current.selectedSpaceId,
        allSpaces: current.allSpaces,
      );
    } catch (_) {
      emit(const ArticlesFailure('Makale yayınlanamadı.'));
    }
  }

  Future<void> delete(String articleId) async {
    final current = state;
    if (current is! ArticlesLoaded) {
      return;
    }

    try {
      await _articlesRepository.deleteArticle(articleId);
      await load(
        spaceId: current.selectedSpaceId,
        allSpaces: current.allSpaces,
      );
    } catch (_) {
      emit(const ArticlesFailure('Makale silinemedi.'));
    }
  }

  Future<void> favorite(String articleId, bool isFavorite) async {
    final current = state;
    if (current is! ArticlesLoaded) {
      return;
    }

    try {
      await _articlesRepository.favoriteArticle(
        articleId,
        isFavorite: isFavorite,
      );
      await load(
        spaceId: current.selectedSpaceId,
        allSpaces: current.allSpaces,
      );
    } catch (_) {
      emit(const ArticlesFailure('Makale güncellenemedi.'));
    }
  }

  Future<void> archive(String articleId) async {
    final current = state;
    if (current is! ArticlesLoaded) {
      return;
    }

    try {
      await _articlesRepository.archiveArticle(articleId);
      await load(
        spaceId: current.selectedSpaceId,
        allSpaces: current.allSpaces,
      );
    } catch (_) {
      emit(const ArticlesFailure('Makale arşivlenemedi.'));
    }
  }

  int _readingTime(String content) {
    final words = content.trim().split(RegExp(r'\s+')).where((word) {
      return word.trim().isNotEmpty;
    }).length;

    return words == 0 ? 1 : (words / 220).ceil();
  }
}
