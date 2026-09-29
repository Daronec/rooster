import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_model.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_wm.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/desktop/auth_screen_desktop.dart';
import 'package:rooster/features/auth/presentation/screens/auth/widgets/mobile/auth_screen_mobile.dart';

/// Экран входа через Sber ID.
@RoutePage(name: 'AuthRoute')
class AuthScreen extends BaseWidget<AuthScreenWidgetModel> {
  /// Создаёт экран.
  const AuthScreen({super.key}) : super(authScreenWidgetModelFactory);

  @override
  Widget buildDesktop(AuthScreenWidgetModel wm) => AuthScreenDesktop(wm: wm);

  @override
  Widget buildMobile(AuthScreenWidgetModel wm) => AuthScreenMobile(wm: wm);
}

/// Фабрика WM.
AuthScreenWidgetModel authScreenWidgetModelFactory(BuildContext context) {
  final snack = SnackQueueProvider.of(context);
  return AuthScreenWidgetModel(
    AuthScreenModel(
      authGateway: context.read<IAppScope>().authGateway,
    ),
    snackController: snack,
  );
}
