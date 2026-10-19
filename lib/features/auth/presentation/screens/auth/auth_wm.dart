import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/data/services/social_auth_service_types.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_vk_id_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_yandex_id_gateway.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_model.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:rooster/features/navigation/root_main_app_route.dart'
    show rootMainAppStackOpenProfileRoutes;
import 'package:yandex_login_sdk/yandex_login_sdk.dart';

/// WidgetModel экрана авторизации (VK ID / Yandex ID).
class AuthScreenWidgetModel
    extends BaseWidgetModel<AuthScreen, AuthScreenModel> {
  /// Создаёт widget model.
  AuthScreenWidgetModel(
    super.model, {
    required super.snackController,
  });

  StreamSubscription<AppAuthUserEntity?>? _authSub;

  /// Gateway для входа через VK ID (через model).
  IVkIdGateway get vkIdGateway => model.vkIdGateway;

  /// Gateway для входа через Yandex ID (через model).
  IYandexIdGateway get yandexIdGateway => model.yandexIdGateway;

  /// Основной шлюз авторизации (через model).
  IAuthGateway get authGateway => model.authGateway;

  /// Текст вступления под выбранную стратегию авторизации.
  String get introTranslationKey => model.introTranslationKey;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    if (model.hasSession) {
      _navigateMain();
    }
    _authSub = model.authStateChanges.listen((sessionUser) {
      if (sessionUser != null) {
        _navigateMain();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Вход через VK ID.
  Future<void> onVkIdTap() async {
    try {
      await vkIdGateway.signInWithVkId();
    } on SocialAuthCanceledException {
      // User cancelled -- silent return, no snack
      return;
    } on Exception {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.vkSignInFailed'),
        messageType: SnackMessageType.error,
      );
    }
  }

  /// Вход через Yandex ID.
  Future<void> onYandexIdTap() async {
    try {
      await yandexIdGateway.signInWithYandexId();
    } on SocialAuthCanceledException {
      // User cancelled -- silent return, no snack
      return;
    } on YandexAuthCancelledException {
      // User cancelled via Yandex SDK -- silent return, no snack
      return;
    } on Exception {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.yandexSignInFailed'),
        messageType: SnackMessageType.error,
      );
    }
  }

  void _navigateMain() {
    late final bool isDesktopLayout;
    late final IAppScope appScope;
    late final StackRouter rootStackRouter;
    try {
      isDesktopLayout = isDesktop;
      appScope = context.read<IAppScope>();
      rootStackRouter = context.router.root;
    } on Object {
      return;
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(appScope.syncManager.requestSync());
      rootStackRouter.replaceAll(
        rootMainAppStackOpenProfileRoutes(isDesktop: isDesktopLayout),
      );
    });
  }
}
