import 'package:flutter/widgets.dart';

/// Persistent storage for app locale.
abstract interface class ILocaleStorage {
  /// Returns saved locale.
  Locale? getLocale();

  /// Saves selected locale.
  Future<void> saveLocale({required Locale locale});
}
// End of file.
