import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:rooster/features/locale_mode/domain/repositories/i_locale_repository.dart';

const Locale _defaultLocale = Locale('ru');

/// [ElementaryModel] for locale feature.
final class LocaleModel extends ElementaryModel {
  /// Creates model.
  LocaleModel({required ILocaleRepository repository}) : _repository = repository;

  final ILocaleRepository _repository;

  final ValueNotifier<Locale> _locale = ValueNotifier<Locale>(_defaultLocale);

  /// Current locale.
  ValueListenable<Locale> get locale => _locale;

  @override
  void init() {
    super.init();
    _locale.value = _repository.getLocale() ?? _defaultLocale;
  }

  /// Persist and update locale.
  Future<void> setLocale(Locale newLocale) async {
    if (newLocale == _locale.value) return;
    await _repository.setLocale(newLocale);
    _locale.value = newLocale;
  }
}
// End of file.
