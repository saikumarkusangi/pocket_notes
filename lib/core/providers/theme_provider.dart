import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pocket_notes/core/constants/app_constants.dart';
import 'package:pocket_notes/core/providers/storage_provider.dart';
import 'package:pocket_notes/core/theme/app_theme.dart';

final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    final prefs = ref.read(sharedPreferencesProvider);
    return _themeModeFromString(prefs.getString(AppConstants.themeStorageKey));
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await ref
        .read(sharedPreferencesProvider)
        .setString(AppConstants.themeStorageKey, mode.name);
  }
}

ThemeMode _themeModeFromString(String? value) {
  return switch (value) {
    'dark' => ThemeMode.dark,
    'light' => ThemeMode.light,
    _ => ThemeMode.system,
  };
}

final lightThemeProvider = Provider<ThemeData>((ref) => AppTheme.lightTheme);

final darkThemeProvider = Provider<ThemeData>((ref) => AppTheme.darkTheme);
