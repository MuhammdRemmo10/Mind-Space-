import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/space.dart';
import '../../domain/repositories/spaces_repository.dart';
import 'spaces_state.dart';

class SpacesCubit extends Cubit<SpacesState> {
  SpacesCubit(this._repository) : super(const SpacesInitial());

  final SpacesRepository _repository;

  Future<void> load() async {
    emit(const SpacesLoading());

    try {
      emit(SpacesLoaded(await _repository.getSpaces(limit: 100)));
    } catch (_) {
      emit(const SpacesFailure('Alanlar yüklenemedi.'));
    }
  }

  Future<void> create({
    required String name,
    String? description,
    required Color color,
  }) async {
    try {
      await _repository.createSpace(
        Space(
          id: '',
          name: name,
          description: description,
          icon: Icons.space_dashboard_outlined,
          color: color,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        ),
      );
      await load();
    } catch (_) {
      emit(const SpacesFailure('Alan oluşturulamadı.'));
    }
  }

  Future<void> update({
    required Space space,
    required String name,
    String? description,
    required Color color,
  }) async {
    try {
      await _repository.updateSpace(
        Space(
          id: space.id,
          name: name,
          description: description,
          icon: space.icon,
          color: color,
          createdAt: space.createdAt,
          updatedAt: DateTime.now(),
          isFavorite: space.isFavorite,
          isPinned: space.isPinned,
          status: space.status,
        ),
      );
      await load();
    } catch (_) {
      emit(const SpacesFailure('Alan güncellenemedi.'));
    }
  }

  Future<void> delete(String id) async {
    try {
      await _repository.deleteSpace(id);
      await load();
    } catch (_) {
      emit(const SpacesFailure('Alan silinemedi.'));
    }
  }
}
