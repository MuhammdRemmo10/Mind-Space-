import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/domain/visibility_level.dart';
import '../../../spaces/domain/repositories/spaces_repository.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/notes_repository.dart';
import 'notes_state.dart';

class NotesCubit extends Cubit<NotesState> {
  NotesCubit(this._notesRepository, this._spacesRepository)
    : super(const NotesInitial());

  final NotesRepository _notesRepository;
  final SpacesRepository _spacesRepository;

  Future<void> load({String? spaceId}) async {
    emit(const NotesLoading());

    try {
      final spaces = await _spacesRepository.getSpaces(limit: 100);
      final selectedSpaceId =
          spaceId ?? (spaces.isNotEmpty ? spaces.first.id : null);
      final notes = selectedSpaceId == null
          ? <Note>[]
          : await _notesRepository.getNotes(spaceId: selectedSpaceId);

      emit(
        NotesLoaded(
          notes: notes,
          spaces: spaces,
          selectedSpaceId: selectedSpaceId,
        ),
      );
    } catch (_) {
      emit(const NotesFailure('Notlar yüklenemedi.'));
    }
  }

  Future<void> create({
    required String spaceId,
    required String title,
    required String content,
    required VisibilityLevel visibility,
  }) async {
    try {
      await _notesRepository.createNote(
        Note(
          id: '',
          spaceId: spaceId,
          title: title,
          richText: content,
          description: content,
          visibility: visibility,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await load(spaceId: spaceId);
    } catch (_) {
      emit(const NotesFailure('Not oluşturulamadı.'));
    }
  }

  Future<void> delete(String noteId) async {
    final currentState = state;
    if (currentState is! NotesLoaded) {
      return;
    }

    try {
      await _notesRepository.trashNote(noteId);
      await load(spaceId: currentState.selectedSpaceId);
    } catch (_) {
      emit(const NotesFailure('Not silinemedi.'));
    }
  }

  Future<void> favorite(String noteId, bool isFavorite) async {
    final currentState = state;
    if (currentState is! NotesLoaded) {
      return;
    }

    try {
      await _notesRepository.favoriteNote(noteId, isFavorite: isFavorite);
      await load(spaceId: currentState.selectedSpaceId);
    } catch (_) {
      emit(const NotesFailure('Not güncellenemedi.'));
    }
  }

  Future<void> archive(String noteId) async {
    final currentState = state;
    if (currentState is! NotesLoaded) {
      return;
    }

    try {
      await _notesRepository.archiveNote(noteId);
      await load(spaceId: currentState.selectedSpaceId);
    } catch (_) {
      emit(const NotesFailure('Not arşivlenemedi.'));
    }
  }
}
