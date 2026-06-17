import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_model.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/root_auth_gate_wm.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/desktop/root_auth_gate_screen_desktop.dart';
import 'package:rooster/features/auth/presentation/root_auth_gate/widgets/mobile/root_auth_gate_screen_mobile.dart';

/// Корневой шлюз: загрузка сессии и переход на авторизацию или задачи.
@RoutePage(name: 'RootAuthGateRoute')
class RootAuthGateScreen extends BaseWidget<RootAuthGateWidgetModel> {
  /// Создаёт экран.
  const RootAuthGateScreen({super.key}) : super(rootAuthGateWidgetModelFactory);

  @override
  Widget buildDesktop(RootAuthGateWidgetModel wm) =>
      RootAuthGateScreenDesktop(wm: wm);

  @override
  Widget buildMobile(RootAuthGateWidgetModel wm) =>
      RootAuthGateScreenMobile(wm: wm);
}

/// Фабрика [RootAuthGateWidgetModel].
RootAuthGateWidgetModel rootAuthGateWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  return RootAuthGateWidgetModel(
    RootAuthGateModel(
      authGateway: scope.authGateway,
      authBackendStrategy: scope.authBackendStrategy,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
