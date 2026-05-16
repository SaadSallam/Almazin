import 'package:flutter/material.dart';

enum ThemePreference { light, dark, system }

ThemePreference? decodeThemePreference(String? raw) {
  return switch (raw) {
    'light' => ThemePreference.light,
    'dark' => ThemePreference.dark,
    'system' => ThemePreference.system,
    _ => null,
  };
}

extension ThemePreferenceX on ThemePreference {
  String encode() => switch (this) {
        ThemePreference.light => 'light',
        ThemePreference.dark => 'dark',
        ThemePreference.system => 'system',
      };

  ThemeMode toThemeMode() => switch (this) {
        ThemePreference.light => ThemeMode.light,
        ThemePreference.dark => ThemeMode.dark,
        ThemePreference.system => ThemeMode.system,
      };
}

ThemePreference themePreferenceFromThemeMode(ThemeMode mode) {
  return switch (mode) {
    ThemeMode.light => ThemePreference.light,
    ThemeMode.dark => ThemePreference.dark,
    ThemeMode.system => ThemePreference.system,
  };
}
