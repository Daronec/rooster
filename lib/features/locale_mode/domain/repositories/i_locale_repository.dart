import 'package:flutter/widgets.dart';

/// Repository for app locale.
abstract interface class ILocaleRepository {
  /// Persist selected locale.
  Future<void> setLocale(Locale locale);

  /// Returns persisted locale.
  ///
  /// If null, locale was not set yet.
  Locale? getLocale();
}
// End of file.
