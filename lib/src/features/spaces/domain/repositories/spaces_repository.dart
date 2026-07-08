import '../entities/space.dart';

abstract class SpacesRepository {
  Future<List<Space>> getSpaces({int page = 1, int limit = 20});
  Future<Space> createSpace(Space space);
  Future<Space> updateSpace(Space space);
  Future<void> archiveSpace(String id);
  Future<void> favoriteSpace(String id, {required bool isFavorite});
  Future<void> pinSpace(String id, {required bool isPinned});
  Future<void> deleteSpace(String id);
  Future<void> restoreSpace(String id);
}
