import 'package:equatable/equatable.dart';

import '../../domain/entities/space.dart';

sealed class SpacesState extends Equatable {
  const SpacesState();

  @override
  List<Object?> get props => [];
}

class SpacesInitial extends SpacesState {
  const SpacesInitial();
}

class SpacesLoading extends SpacesState {
  const SpacesLoading();
}

class SpacesLoaded extends SpacesState {
  const SpacesLoaded(this.spaces);

  final List<Space> spaces;

  @override
  List<Object?> get props => [spaces];
}

class SpacesFailure extends SpacesState {
  const SpacesFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
