import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_model.dart';
import 'package:rooster/features/settings/presentation/screens/settings/settings_wm.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/desktop/settings_screen_desktop.dart';
import 'package:rooster/features/settings/presentation/screens/settings/widgets/mobile/settings_screen_mobile.dart';

/// Настройки приложения.
@RoutePage(name: 'SettingsRoute')
class SettingsScreen extends BaseWidget<SettingsScreenWidgetModel> {
  /// Создаёт экран.
  const SettingsScreen({super.key}) : super(settingsScreenWidgetModelFactory);

  @override
  Widget buildDesktop(SettingsScreenWidgetModel wm) =>
      SettingsScreenDesktop(wm: wm);

  @override
  Widget buildMobile(SettingsScreenWidgetModel wm) =>
      SettingsScreenMobile(wm: wm);
}

/// Фабрика [SettingsScreenWidgetModel].
SettingsScreenWidgetModel settingsScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return SettingsScreenWidgetModel(
    SettingsScreenModel(),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
