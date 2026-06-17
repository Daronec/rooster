import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_model.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/dev_panel_wm.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/desktop/dev_panel_screen_desktop.dart';
import 'package:rooster/features/dev_panel/presentation/screens/dev_panel/widgets/mobile/dev_panel_screen_mobile.dart';

/// Dev: очередь и сеть.
@RoutePage(name: 'DevPanelRoute')
class DevPanelScreen extends BaseWidget<DevPanelScreenWidgetModel> {
  /// Создаёт экран.
  const DevPanelScreen({super.key}) : super(devPanelScreenWidgetModelFactory);

  @override
  Widget buildDesktop(DevPanelScreenWidgetModel wm) =>
      DevPanelScreenDesktop(wm: wm);

  @override
  Widget buildMobile(DevPanelScreenWidgetModel wm) =>
      DevPanelScreenMobile(wm: wm);
}

/// Фабрика [DevPanelScreenWidgetModel] с sync-зависимостями из scope.
DevPanelScreenWidgetModel devPanelScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return DevPanelScreenWidgetModel(
    DevPanelScreenModel(syncQueue: scope.syncQueue),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
    syncManager: scope.syncManager,
    connectivity: scope.connectivityGateway,
    syncEngineListenable: scope.syncEngineListenable,
  );
}
