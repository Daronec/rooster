import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:rooster/features/locale_mode/di/locale_scope.dart';
import 'package:rooster/features/locale_mode/presentation/locale_controller.dart';
import 'package:rooster/features/locale_mode/presentation/locale_model.dart';
import 'package:rooster/features/locale_mode/presentation/locale_widget.dart';

/// DI factory for [LocaleWM].
LocaleWM defaultLocaleWMFactory(BuildContext context) {
  final scope = context.read<ILocaleScope>();
  return LocaleWM(LocaleModel(repository: scope.repository));
}

/// Interface for [LocaleWM].
abstract interface class ILocaleWM
    implements LocaleController, IWidgetModel {}

/// [WidgetModel] for [LocaleWidget].
final class LocaleWM extends WidgetModel<LocaleWidget, LocaleModel>
    implements ILocaleWM {
  /// Creates WM.
  LocaleWM(super._model);

  @override
  ValueListenable<Locale> get locale => model.locale;

  @override
  Future<void> setLocale(Locale locale) => model.setLocale(locale);
}
// End of file.
