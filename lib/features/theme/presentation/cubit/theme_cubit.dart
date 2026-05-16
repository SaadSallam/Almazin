import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/theme_preference.dart';
import '../../domain/theme_repository.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit(this._repository) : super(const ThemeState(ThemeMode.light)) {
    _restore();
  }

  final ThemeRepository _repository;

  Future<void> _restore() async {
    final saved = await _repository.load();
    final mode = saved?.toThemeMode() ?? ThemeMode.light;
    emit(ThemeState(mode));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    await _repository.save(themePreferenceFromThemeMode(mode));
    emit(ThemeState(mode));
  }
}
