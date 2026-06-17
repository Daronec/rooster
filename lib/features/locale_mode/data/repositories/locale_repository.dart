import 'package:flutter/widgets.dart';
import 'package:rooster/features/locale_mode/domain/repositories/i_locale_repository.dart';
import 'package:rooster/persistence/storage/locale_storage/i_locale_storage.dart';

/// Implementation of [ILocaleRepository].
final class LocaleRepository implements ILocaleRepository {
  /// Creates repository instance.
  const LocaleRepository({required ILocaleStorage localeStorage})
    : _localeStorage = localeStorage;

  final ILocaleStorage _localeStorage;

  @override
  Locale? getLocale() => _localeStorage.getLocale();

  @override
  Future<void> setLocale(Locale locale) => _localeStorage.saveLocale(locale: locale);
}
// End of file.
