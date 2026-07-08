import 'package:equatable/equatable.dart';

import '../../../spaces/domain/entities/space.dart';
import '../../domain/entities/note.dart';

sealed class NotesState extends Equatable {
  const NotesState();

  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {
  const NotesInitial();
}

class NotesLoading extends NotesState {
  const NotesLoading();
}

class NotesLoaded extends NotesState {
  const NotesLoaded({
    required this.notes,
    required this.spaces,
    this.selectedSpaceId,
  });

  final List<Note> notes;
  final List<Space> spaces;
  final String? selectedSpaceId;

  @override
  List<Object?> get props => [notes, spaces, selectedSpaceId];
}

class NotesFailure extends NotesState {
  const NotesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
