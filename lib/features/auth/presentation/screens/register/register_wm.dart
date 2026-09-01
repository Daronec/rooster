import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:auto_route/auto_route.dart';
import 'package:elementary/elementary.dart' show WidgetModel;
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_exception.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_reason.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_model.dart';
import 'package:rooster/features/auth/presentation/screens/register/register_screen.dart';
import 'package:rooster/features/navigation/root_main_app_route.dart'
    show rootMainAppStackOpenProfileRoutes;

/// [WidgetModel] экрана регистрации.
class RegisterScreenWidgetModel
    extends BaseWidgetModel<RegisterScreen, RegisterScreenModel> {
  /// Создаёт WM.
  RegisterScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(
         handledFailureLogWriter: logWriter,
       );

  StreamSubscription<AppAuthUserEntity?>? _authSub;

  /// Поле email.
  late final TextEditingController emailFieldController;

  /// Поле пароля.
  late final TextEditingController passwordFieldController;

  /// Поле подтверждения пароля.
  late final TextEditingController passwordConfirmFieldController;

  /// Поле имени.
  late final TextEditingController nameFieldController;

  /// Поле телефона (E.164).
  late final TextEditingController phoneFieldController;

  static final RegExp _e164PhonePattern = RegExp(r'^\+[1-9]\d{9,14}$');

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    emailFieldController = TextEditingController();
    passwordFieldController = TextEditingController();
    passwordConfirmFieldController = TextEditingController();
    nameFieldController = TextEditingController();
    phoneFieldController = TextEditingController();
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
    passwordConfirmFieldController.dispose();
    nameFieldController.dispose();
    phoneFieldController.dispose();
    super.dispose();
  }

  /// Отправка формы регистрации.
  Future<void> onSubmitRegister() async {
    final emailText = emailFieldController.text.trim();
    final passwordText = passwordFieldController.text;
    final confirmText = passwordConfirmFieldController.text;
    final nameText = nameFieldController.text.trim();
    final phoneText = phoneFieldController.text.trim();

    if (emailText.isEmpty ||
        passwordText.isEmpty ||
        confirmText.isEmpty ||
        nameText.isEmpty ||
        phoneText.isEmpty) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.registerFieldsRequired'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    if (!_e164PhonePattern.hasMatch(phoneText)) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.phoneInvalidE164'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    if (nameText.length > 128) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.registerNameTooLong'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    if (passwordText.length < 8) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.passwordTooShort'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    if (passwordText != confirmText) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.passwordMismatch'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    if (!emailText.contains('@')) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.registerEmailInvalid'),
        messageType: SnackMessageType.error,
      );
      return;
    }

    try {
      await model.signUpWithProfile(
        email: emailText,
        password: passwordText,
        name: nameText,
        phoneE164: phoneText,
      );
      if (!model.hasSession) {
        snackController.addSnack(
          FlutterI18n.translate(context, 'auth.appwriteEmailConfirmSignup'),
          messageType: SnackMessageType.success,
        );
        return;
      }
      _navigateMain();
    } on Object catch (error) {
      _onRegisterError(error);
    }
  }

  void _onRegisterError(Object error) {
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
    if (error is ArgumentError) {
      snackController.addSnack(
        FlutterI18n.translate(context, 'auth.registerValidationFailed'),
        messageType: SnackMessageType.error,
      );
      return;
    }
    onErrorHandle(error);
  }

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

  static String _appwriteAuthErrorTranslationKey(AppwriteException exception) {
    final statusCode = exception.code;
    if (statusCode == 401 || statusCode == 403) {
      return 'auth.appwriteInvalidCredentials';
    }
    return 'auth.signInFailed';
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
