import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/error/app_exception.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit(this._repository) : super(const AuthInitial());

  final AuthRepository _repository;

  Future<void> login({
    required String email,
    required String password,
    required bool rememberMe,
  }) async {
    emit(const AuthLoading());

    try {
      await _repository.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );
      emit(const Authenticated());
    } on AppException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(const AuthFailure('E-posta adresi veya şifre hatalı.'));
    }
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      await _repository.register(
        fullName: fullName,
        username: username,
        email: email,
        password: password,
      );
      emit(const Authenticated());
    } on AppException catch (error) {
      emit(AuthFailure(error.message));
    } catch (_) {
      emit(const AuthFailure('Hesap oluşturulamadı. Bilgilerini kontrol et.'));
    }
  }
}
