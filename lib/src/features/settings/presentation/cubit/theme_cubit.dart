import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeCubit extends Cubit<ThemeMode> {
  ThemeCubit(this._preferences) : super(_readThemeMode(_preferences));

  static const String _themeKey = 'theme_mode';

  final SharedPreferences _preferences;

  Future<void> setThemeMode(ThemeMode mode) async {
    await _preferences.setString(_themeKey, mode.name);
    emit(mode);
  }

  static ThemeMode _readThemeMode(SharedPreferences preferences) {
    final value = preferences.getString(_themeKey);
    return ThemeMode.values.firstWhere(
      (mode) => mode.name == value,
      orElse: () => ThemeMode.system,
    );
  }
}
