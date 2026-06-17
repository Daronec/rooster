import 'package:flutter/widgets.dart';
import 'package:rooster/persistence/storage/locale_storage/i_locale_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persistent storage for app locale.
///
/// Based on SharedPreferences.
final class LocaleStorage implements ILocaleStorage {
  /// Creates storage instance.
  const LocaleStorage(this._prefs);

  final SharedPreferences _prefs;

  @override
  Locale? getLocale() {
    final languageCode = _prefs.getString(LocaleStorageKeys.languageCode.keyName);
    if (languageCode?.isEmpty ?? true) return null;
    return Locale(languageCode!);
  }

  @override
  Future<void> saveLocale({required Locale locale}) {
    return _prefs.setString(LocaleStorageKeys.languageCode.keyName, locale.languageCode);
  }
}

/// Keys for [LocaleStorage].
enum LocaleStorageKeys {
  /// Locale language code.
  languageCode('app_locale_language_code');

  /// Key name.
  final String keyName;

  const LocaleStorageKeys(this.keyName);
}
// End of file.
