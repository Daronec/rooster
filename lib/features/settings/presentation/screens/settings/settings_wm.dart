import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/widgets.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/locale_mode/presentation/locale_provider.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_model.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_screen.dart';
import 'package:rooster/features/theme_mode/presentation/theme_mode_provider.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// WM настроек.
class SettingsScreenWidgetModel
    extends BaseWidgetModel<SettingsScreen, SettingsScreenModel> {
  /// Создаёт WM.
  SettingsScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : bodyState = UnionStateNotifier<EmptyScreenBody>(EmptyScreenBody.instance),
       super(
         handledFailureLogWriter: logWriter,
       );

  /// Состояние тела экрана.
  final UnionStateNotifier<EmptyScreenBody> bodyState;

  /// Вернуть тело экрана в контент после ошибки.
  void retryScreenBody() {
    bodyState.content(EmptyScreenBody.instance);
  }

  /// Переключение светлой/тёмной темы через [ThemeModeProvider].
  Future<void> onToggleTheme() async {
    await ThemeModeProvider.of(context).switchThemeMode();
  }

  /// Установить язык приложения.
  Future<void> onSelectLanguage(String languageCode) async {
    await LocaleProvider.of(context).setLocale(Locale(languageCode));
  }

  /// Вернуться назад по стеку навигации.
  void onBackPressed() {
    unawaited(context.router.maybePop());
  }

  @override
  void dispose() {
    bodyState.dispose();
    super.dispose();
  }
}
