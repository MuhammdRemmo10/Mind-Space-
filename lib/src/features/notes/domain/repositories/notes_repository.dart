import '../../../../core/domain/entity_status.dart';
import '../entities/note.dart';

abstract class NotesRepository {
  Future<List<Note>> getNotes({
    String? spaceId,
    EntityStatus? status,
    bool favoritesOnly = false,
    int page = 1,
    int limit = 20,
  });

  Future<Note> createNote(Note note);
  Future<Note> updateNote(Note note);
  Future<Note> duplicateNote(String id);
  Future<void> moveNote({
    required String noteId,
    required String targetSpaceId,
  });
  Future<void> archiveNote(String id);
  Future<void> favoriteNote(String id, {required bool isFavorite});
  Future<void> trashNote(String id);
  Future<void> restoreNote(String id);
}
