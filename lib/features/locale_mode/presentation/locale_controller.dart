import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Holds and controls app locale.
abstract interface class LocaleController {
  /// Current locale.
  ValueListenable<Locale> get locale;

  /// Set locale.
  Future<void> setLocale(Locale locale);
}
// End of file.
