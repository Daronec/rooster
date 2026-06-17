import 'package:flutter/material.dart';
import 'package:rooster/features/theme_mode/domain/repositories/i_theme_mode_repository.dart';
import 'package:rooster/persistence/storage/theme_storage/i_theme_mode_storage.dart';

/// {@template theme_repository.class}
/// Implementation of [IThemeModeRepository].
/// {@endtemplate}
final class ThemeModeRepository implements IThemeModeRepository {

  /// {@macro theme_repository.class}
  const ThemeModeRepository({required IThemeModeStorage themeModeStorage})
    : _themeModeStorage = themeModeStorage;
  final IThemeModeStorage _themeModeStorage;

  @override
  Future<void> setThemeMode(ThemeMode newThemeMode) async {
    await _themeModeStorage.saveThemeMode(mode: newThemeMode);
  }

  @override
  ThemeMode? getThemeMode() {
    return _themeModeStorage.getThemeMode();
  }
}
