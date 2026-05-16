import 'package:hive_flutter/hive_flutter.dart';

import '../domain/theme_preference.dart';
import '../domain/theme_repository.dart';

class ThemeRepositoryImpl implements ThemeRepository {
  ThemeRepositoryImpl(this._box);

  final Box<dynamic> _box;

  static const String storageKey = 'theme_preference';

  @override
  Future<ThemePreference?> load() async {
    final raw = _box.get(storageKey) as String?;
    return decodeThemePreference(raw);
  }

  @override
  Future<void> save(ThemePreference preference) async {
    await _box.put(storageKey, preference.encode());
  }
}
