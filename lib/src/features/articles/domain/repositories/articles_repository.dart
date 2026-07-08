import '../../../../core/domain/entity_status.dart';
import '../../../../core/domain/visibility_level.dart';
import '../entities/article.dart';

abstract class ArticlesRepository {
  Future<List<Article>> getArticles({
    String? spaceId,
    EntityStatus? status,
    bool favoritesOnly = false,
    int page = 1,
    int limit = 20,
  });

  Future<Article> createArticle(
    Article article, {
    String? coverImagePath,
    bool publishNow = false,
  });
  Future<Article> updateArticle(Article article);
  Future<Article> publishArticle(String id, {VisibilityLevel? visibility});
  Future<void> archiveArticle(String id);
  Future<void> favoriteArticle(String id, {required bool isFavorite});
  Future<void> deleteArticle(String id);
  Future<void> restoreArticle(String id);
}
