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
  bool _isNavigating = false;

  /// Текст вступления под выбранную стратегию авторизации.
  String get introTranslationKey => model.introTranslationKey;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    debugPrint(
      'AuthScreenWidgetModel: initWidgetModel hasSession=${model.hasSession}',
    );
    _authSub = model.authStateChanges.listen(
      (sessionUser) {
        debugPrint(
          'AuthScreenWidgetModel: authStateChanges received user=${sessionUser?.uid ?? "null"}',
        );
        if (sessionUser != null && !_isNavigating) {
          _navigateMain();
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'AuthScreenWidgetModel: authStateChanges error: $error',
        );
      },
    );
  }

  @override
  void dispose() {
    _authSub?.cancel();
    super.dispose();
  }

  /// Вход через VK ID.
  Future<void> onVkIdTap() async {
    try {
      await model.signInWithVkId();
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
      await model.signInWithYandexId();
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
    debugPrint('AuthScreenWidgetModel: _navigateMain called');
    late final bool isDesktopLayout;
    late final IAppScope appScope;
    late final StackRouter rootStackRouter;
    try {
      isDesktopLayout = isDesktop;
      appScope = context.read<IAppScope>();
      rootStackRouter = context.router.root;
    } on Object {
      debugPrint('AuthScreenWidgetModel: _navigateMain failed to get context');
      return;
    }
    _isNavigating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      debugPrint('AuthScreenWidgetModel: navigating to main app (profile)');
      unawaited(appScope.syncManager.requestSync());
      // Navigate to main app with profile, replacing auth flow
      rootStackRouter.replaceAll(
        rootMainAppStackOpenProfileRoutes(isDesktop: isDesktopLayout),
      );
      debugPrint('AuthScreenWidgetModel: navigation completed');
    });
  }
}
