import '../entities/mind_file.dart';

abstract class FilesRepository {
  Future<List<MindFile>> getFiles({int page = 1, int limit = 20});
}
