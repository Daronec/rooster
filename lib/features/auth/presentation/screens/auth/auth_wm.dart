import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:elementary/elementary.dart' show WidgetModel;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_exception.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_reason.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_model.dart';
import 'package:rooster/features/auth/presentation/screens/auth/auth_screen.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/navigation/root_main_app_route.dart'
    show rootMainAppStackOpenProfileRoutes;
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// {@template auth_wm.class}
/// [WidgetModel] экрана авторизации (Appwrite).
/// {@endtemplate}
class AuthScreenWidgetModel
    extends BaseWidgetModel<AuthScreen, AuthScreenModel> {
  /// {@macro auth_wm.class}
  AuthScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : bodyState = UnionStateNotifier<EmptyScreenBody>(EmptyScreenBody.instance),
       super(
         handledFailureLogWriter: logWriter,
       );

  /// Состояние тела экрана (для [UnionStateListenableBuilder]).
  final UnionStateNotifier<EmptyScreenBody> bodyState;

  StreamSubscription<AppAuthUserEntity?>? _authSub;

  /// Поле email.
  late final TextEditingController emailFieldController;

  /// Поле пароля.
  late final TextEditingController passwordFieldController;

  /// Вернуть тело экрана в состояние контента после ошибки.
  void retryScreenBody() {
    bodyState.content(EmptyScreenBody.instance);
  }

  /// Стратегия облака для экрана входа.
  AuthBackendStrategy get authBackendStrategy => model.authBackendStrategy;

  /// Кнопка Google (Android, Appwrite OAuth).
  bool get showGoogleSignInButton => model.showGoogleSignInButton;

  /// Кнопка Apple (iOS, Appwrite OAuth).
  bool get showAppleSignInButton => model.showAppleSignInButton;

  /// Текст вступления под выбранную стратегию авторизации.
  String get introTranslationKey => model.authIntroTranslationKey;

  /// Форма email и пароль (web, desktop).
  bool get supportsEmailPasswordAuth => model.supportsEmailPasswordAuth;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    emailFieldController = TextEditingController();
    passwordFieldController = TextEditingController();
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
    emailFieldController.dispose();
    passwordFieldController.dispose();
    bodyState.dispose();
    super.dispose();
  }

  /// Вход через Google (Appwrite).
  Future<void> onGoogleTap() async {
    try {
      await model.signInGoogle();
      _navigateMain();
    } on PlatformException catch (platformError) {
      logHandledFailureSeparateFromUserMessage(platformError);
      final messageKey = _googleSignInPlatformErrorTranslationKey(
        platformError,
      );
      snackController.addSnack(
        FlutterI18n.translate(context, messageKey),
        messageType: SnackMessageType.error,
      );
    } on Object catch (error) {
      _onAuthFlowObjectError(error);
    }
  }

  /// Ключ строки локализации для ошибки платформы OAuth Google.
  String _googleSignInPlatformErrorTranslationKey(PlatformException error) {
    final details = error.message ?? '';
    if (details.contains('ApiException: 10')) {
      return 'auth.googleSignInFailedDeveloper';
    }
    if (error.code == 'sign_in_failed') {
      return 'auth.googleSignInFailedPlayServices';
    }
    return 'auth.signInFailed';
  }

  /// Вход через Apple (Appwrite).
  Future<void> onAppleTap() async {
    try {
      await model.signInApple();
      _navigateMain();
    } on Object catch (error) {
      _onAuthFlowObjectError(error);
    }
  }

  /// Вход по email и паролю.
  Future<void> onEmailSignInTap() async {
    final emailText = emailFieldController.text.trim();
    final passwordText = passwordFieldController.text;
    if (emailText.isEmpty || passwordText.isEmpty) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.emailPasswordRequired'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    try {
      await model.signInEmailPassword(
        email: emailText,
        password: passwordText,
      );
      _navigateMain();
    } on Object catch (error) {
      _onAuthFlowObjectError(error);
    }
  }

  /// Открыть экран регистрации (email, пароль, имя, телефон).
  void onOpenRegisterScreen() {
    unawaited(context.router.push<void>(const RegisterRoute()));
  }

  /// Запрос письма для сброса пароля.
  Future<void> onForgotPasswordTap() async {
    final emailText = emailFieldController.text.trim();
    if (emailText.isEmpty) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.emailRequiredForReset'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    try {
      await model.sendPasswordResetEmail(emailText);
      snackController.addSnack(
        FlutterI18n.translate(
          context,
          model.passwordResetSuccessTranslationKey,
        ),
        messageType: SnackMessageType.success,
      );
    } on ArgumentError catch (_) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.emailRequiredForReset'),
        messageType: SnackMessageType.error,
      );
    } on Object catch (error) {
      _onAuthFlowObjectError(error);
    }
  }

  /// Ключ строки для [CloudAuthUnavailableException].
  static String _cloudAuthUnavailableTranslationKey(
    CloudAuthUnavailableReason reason,
  ) {
    switch (reason) {
      case CloudAuthUnavailableReason.cloudNotConfigured:
        return 'auth.cloudSignInBlockedCloudNotConfigured';
      case CloudAuthUnavailableReason.cloudDisabledByDevicePolicy:
        return 'auth.cloudSignInBlockedOfflineOnlyDevice';
      case CloudAuthUnavailableReason.hmsHostNonFirebaseProviders:
        return 'auth.hmsHostNonFirebaseProviders';
      case CloudAuthUnavailableReason.emailPasswordAuthNotSupported:
        return 'auth.emailPasswordAuthNotSupported';
      case CloudAuthUnavailableReason.phoneOtpAuthNotSupported:
        return 'auth.phoneOtpAuthNotSupported';
      case CloudAuthUnavailableReason.huaweiSignInUnavailableOnFirebaseBackend:
        return 'auth.huaweiSignInUnavailableOnFirebaseBackend';
      case CloudAuthUnavailableReason.huaweiSignInUnavailable:
        return 'auth.huaweiSignInUnavailable';
      case CloudAuthUnavailableReason.appwriteNotConfigured:
        return 'auth.cloudSignInBlockedAppwriteNotConfigured';
      case CloudAuthUnavailableReason.anonymousAuthNotSupported:
        return 'auth.anonymousAuthNotSupported';
    }
  }

  /// Ключ строки для типичных ошибок [AppwriteException].
  static String _appwriteAuthErrorTranslationKey(AppwriteException exception) {
    final statusCode = exception.code;
    if (statusCode == 401 || statusCode == 403) {
      return 'auth.appwriteInvalidCredentials';
    }
    return 'auth.signInFailed';
  }

  void _onAuthFlowObjectError(Object error) {
    if (error is AppwriteException) {
      logHandledFailureSeparateFromUserMessage(error);
      snackController.addSnack(
        FlutterI18n.translate(
          context,
          _appwriteAuthErrorTranslationKey(error),
        ),
        messageType: SnackMessageType.error,
      );
      return;
    }
    if (error is CloudAuthUnavailableException) {
      snackController.addSnack(
        FlutterI18n.translate(
          context,
          _cloudAuthUnavailableTranslationKey(error.reason),
        ),
        messageType: SnackMessageType.error,
      );
      return;
    }
    onErrorHandle(error);
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
