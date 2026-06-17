import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/theme_mode/data/repositories/theme_mode_repository.dart';
import 'package:rooster/persistence/storage/theme_storage/i_theme_mode_storage.dart';

/// In-memory реализация для теста [ThemeModeRepository].
final class _FakeThemeModeStorage implements IThemeModeStorage {
  ThemeMode? _mode;

  @override
  ThemeMode? getThemeMode() => _mode;

  @override
  Future<void> saveThemeMode({required ThemeMode mode}) async {
    _mode = mode;
  }
}

void main() {
  group('ThemeModeRepository', () {
    late _FakeThemeModeStorage storage;
    late ThemeModeRepository repository;

    setUp(() {
      storage = _FakeThemeModeStorage();
      repository = ThemeModeRepository(themeModeStorage: storage);
    });

    test('getThemeMode изначально null', () {
      expect(repository.getThemeMode(), isNull);
    });

    test('setThemeMode сохраняет и getThemeMode возвращает значение', () async {
      await repository.setThemeMode(ThemeMode.dark);
      expect(repository.getThemeMode(), ThemeMode.dark);
    });
  });
}
