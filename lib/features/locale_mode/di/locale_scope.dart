import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/disposable_object/disposable_object.dart';
import 'package:rooster/common/utils/disposable_object/i_disposable_object.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/locale_mode/data/repositories/locale_repository.dart';
import 'package:rooster/features/locale_mode/domain/repositories/i_locale_repository.dart';
import 'package:rooster/persistence/storage/locale_storage/locale_storage.dart';

/// Scope dependencies of locale feature.
abstract interface class ILocaleScope implements IDisposableObject {
  /// Locale repository.
  ILocaleRepository get repository;
}

/// Implementation of [ILocaleScope].
final class LocaleScope extends DisposableObject implements ILocaleScope {
  /// Creates scope instance.
  LocaleScope(this.repository);

  /// Factory constructor for [ILocaleScope].
  factory LocaleScope.create(BuildContext context) {
    final appScope = context.read<IAppScope>();
    final storage = LocaleStorage(appScope.sharedPreferences);
    final repository = LocaleRepository(localeStorage: storage);

    return LocaleScope(repository);
  }

  @override
  final ILocaleRepository repository;
}
// End of file.
