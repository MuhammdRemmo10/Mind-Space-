import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._preferences) : super(_readLocale(_preferences));

  static const String _localeKey = 'app_locale';
  static const List<Locale> supportedLocales = [
    Locale('tr'),
    Locale('ar'),
    Locale('en'),
  ];

  final SharedPreferences _preferences;

  Future<void> useSystemLocale() async {
    await _preferences.remove(_localeKey);
    emit(null);
  }

  Future<void> setLocale(Locale locale) async {
    await _preferences.setString(_localeKey, locale.languageCode);
    emit(locale);
  }

  static Locale? _readLocale(SharedPreferences preferences) {
    final code = preferences.getString(_localeKey);
    if (code == null || code.isEmpty) {
      return null;
    }

    return supportedLocales.firstWhere(
      (locale) => locale.languageCode == code,
      orElse: () => const Locale('tr'),
    );
  }
}
