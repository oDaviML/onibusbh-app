import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'favorites_providers.dart';

enum AppThemeMode { light, dark, system }

class ThemeRepository {
  final SharedPreferences _prefs;
  static const _themeKey = 'theme_mode';

  ThemeRepository(this._prefs);

  AppThemeMode getThemeMode() {
    final saved = _prefs.getString(_themeKey) ?? 'system';
    return AppThemeMode.values.firstWhere(
      (e) => e.name == saved,
      orElse: () => AppThemeMode.system,
    );
  }

  Future<void> saveThemeMode(AppThemeMode mode) async {
    await _prefs.setString(_themeKey, mode.name);
  }
}

final themeRepositoryProvider = Provider<ThemeRepository>((ref) {
  return ThemeRepository(ref.watch(sharedPreferencesProvider));
});

final themeControllerProvider = NotifierProvider<ThemeController, AppThemeMode>(
  () {
    return ThemeController();
  },
);

final themeModeProvider = Provider<ThemeMode>((ref) {
  final appThemeMode = ref.watch(themeControllerProvider);
  switch (appThemeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

class ThemeController extends Notifier<AppThemeMode> {
  @override
  AppThemeMode build() {
    return ref.watch(themeRepositoryProvider).getThemeMode();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    state = mode;
    await ref.read(themeRepositoryProvider).saveThemeMode(mode);
  }

  void cycleTheme() {
    final currentIndex = AppThemeMode.values.indexOf(state);
    final nextIndex = (currentIndex + 1) % AppThemeMode.values.length;
    setThemeMode(AppThemeMode.values[nextIndex]);
  }

  IconData get themeIcon {
    switch (state) {
      case AppThemeMode.light:
        return Icons.dark_mode;
      case AppThemeMode.dark:
        return Icons.brightness_7;
      case AppThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
