import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_model.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_wm.dart';
import 'package:rooster/features/auth/presentation/screens/register/widgets/desktop/register_screen_desktop.dart';
import 'package:rooster/features/auth/presentation/screens/register/widgets/mobile/register_screen_mobile.dart';

/// Экран регистрации (email, пароль, подтверждение, имя, телефон).
@RoutePage(name: 'RegisterRoute')
class RegisterScreen extends BaseWidget<RegisterScreenWidgetModel> {
  /// Создаёт экран.
  const RegisterScreen({super.key}) : super(registerScreenWidgetModelFactory);

  @override
  Widget buildDesktop(RegisterScreenWidgetModel wm) =>
      RegisterScreenDesktop(wm: wm);

  @override
  Widget buildMobile(RegisterScreenWidgetModel wm) =>
      RegisterScreenMobile(wm: wm);
}

/// Фабрика WM.
RegisterScreenWidgetModel registerScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  final snack = SnackQueueProvider.of(context);
  return RegisterScreenWidgetModel(
    RegisterScreenModel(authGateway: scope.authGateway),
    snackController: snack,
    logWriter: scope.logger,
  );
}
