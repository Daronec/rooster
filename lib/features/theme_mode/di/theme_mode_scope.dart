import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/disposable_object/disposable_object.dart';
import 'package:rooster/common/utils/disposable_object/i_disposable_object.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/theme_mode/data/repositories/theme_mode_repository.dart';
import 'package:rooster/features/theme_mode/domain/repositories/i_theme_mode_repository.dart';
import 'package:rooster/persistence/storage/theme_storage/theme_mode_storage.dart';

/// {@template theme_scope.class}
/// Implementation of [IThemeModeScope].
/// {@endtemplate}
final class ThemeModeScope extends DisposableObject implements IThemeModeScope {

  /// {@macro theme_scope.class}
  ThemeModeScope(this.repository);

  /// Factory constructor for [IThemeModeScope].
  factory ThemeModeScope.create(BuildContext context) {
    final appScope = context.read<IAppScope>();
    final storage = ThemeModeStorage(appScope.sharedPreferences);
    final repository = ThemeModeRepository(themeModeStorage: storage);

    return ThemeModeScope(repository);
  }
  @override
  final IThemeModeRepository repository;
}

/// Scope dependencies of the Theme feature.
abstract interface class IThemeModeScope implements IDisposableObject {
  /// ThemeRepository.
  IThemeModeRepository get repository;
}
