import 'theme_preference.dart';

abstract class ThemeRepository {
  /// Returns saved preference, or `null` when nothing has been stored yet.
  Future<ThemePreference?> load();

  Future<void> save(ThemePreference preference);
}
