import '../entities/tag.dart';

abstract class TagsRepository {
  Future<List<Tag>> getTags({int page = 1, int limit = 20});
  Future<Tag> createTag({required String name, required String colorHex});
}
