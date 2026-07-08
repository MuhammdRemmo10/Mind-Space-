import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  ProfileCubit(this._repository) : super(const ProfileInitial());

  final ProfileRepository _repository;

  Future<void> load() async {
    emit(const ProfileLoading());

    try {
      emit(ProfileLoaded(await _repository.getProfile()));
    } catch (_) {
      emit(const ProfileFailure('Profil bilgileri yüklenemedi.'));
    }
  }

  Future<void> update({
    required String fullName,
    required String username,
    String? phoneNumber,
    String? country,
    String? biography,
    String? profilePhotoPath,
    String? coverPhotoPath,
  }) async {
    try {
      final user = await _repository.updateProfile(
        fullName: fullName,
        username: username,
        phoneNumber: phoneNumber,
        country: country,
        biography: biography,
        profilePhotoPath: profilePhotoPath,
        coverPhotoPath: coverPhotoPath,
      );
      emit(ProfileLoaded(user));
    } catch (_) {
      emit(const ProfileFailure('Profil güncellenemedi.'));
    }
  }
}
