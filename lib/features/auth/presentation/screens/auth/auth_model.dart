import 'package:elementary/elementary.dart';
import 'package:rooster/features/auth/domain/appwrite_auth_sign_in_ui_policy.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';

/// Сценарии экрана входа.
final class AuthScreenModel extends ElementaryModel {
  /// Создаёт модель.
  AuthScreenModel({
    required IAuthGateway authGateway,
    required AuthBackendStrategy authBackendStrategy,
    required bool isLikelyHuaweiOrHonorAndroidForAuthUi,
  }) : _authGateway = authGateway,
       _authBackendStrategy = authBackendStrategy,
       _isLikelyHuaweiOrHonorAndroidForAuthUi =
           isLikelyHuaweiOrHonorAndroidForAuthUi;

  final IAuthGateway _authGateway;
  final AuthBackendStrategy _authBackendStrategy;
  final bool _isLikelyHuaweiOrHonorAndroidForAuthUi;

  /// Стратегия облака из корневого scope.
  AuthBackendStrategy get authBackendStrategy => _authBackendStrategy;

  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges =>
      _authGateway.authStateChanges;

  /// Текущий пользователь (если сессия восстановлена).
  bool get hasSession => _authGateway.currentUser != null;

  bool get _isAppwriteCloud =>
      _authBackendStrategy == AuthBackendStrategy.appwrite;

  /// Ключ строки вступления на экране входа.
  String get authIntroTranslationKey {
    if (_authBackendStrategy == AuthBackendStrategy.offlineOnly) {
      return 'auth.introOfflineOnly';
    }
    if (_isAppwriteCloud) {
      if (_isLikelyHuaweiOrHonorAndroidForAuthUi) {
        return 'auth.introAppwriteHuaweiAndroid';
      }
      return 'auth.introAppwrite';
    }
    return 'auth.introOfflineOnly';
  }

  /// Форма email и пароль (web, настольные ОС, Huawei/Honor на Android).
  bool get supportsEmailPasswordAuth =>
      _isAppwriteCloud &&
      AppwriteAuthSignInUiPolicy.offersEmailPasswordSignIn(
        isLikelyHuaweiOrHonorAndroid: _isLikelyHuaweiOrHonorAndroidForAuthUi,
      );

  /// Ключ строки после запроса сброса пароля.
  String get passwordResetSuccessTranslationKey =>
      'auth.appwritePasswordRecoverySent';

  /// Вход Google (Appwrite OAuth, только Android без Huawei/Honor).
  Future<void> signInGoogle() => _authGateway.signInWithGoogle();

  /// Вход Apple (Appwrite OAuth, только iOS).
  Future<void> signInApple() => _authGateway.signInWithApple();

  /// Кнопка Google.
  bool get showGoogleSignInButton =>
      _isAppwriteCloud &&
      AppwriteAuthSignInUiPolicy.offersGoogleSignIn(
        isLikelyHuaweiOrHonorAndroid: _isLikelyHuaweiOrHonorAndroidForAuthUi,
      );

  /// Кнопка Apple.
  bool get showAppleSignInButton =>
      _isAppwriteCloud && AppwriteAuthSignInUiPolicy.offersAppleSignIn();

  /// Вход по email и паролю.
  Future<void> signInEmailPassword({
    required String email,
    required String password,
  }) => _authGateway.signInWithEmailPassword(email: email, password: password);

  /// Сброс пароля по email.
  Future<void> sendPasswordResetEmail(String email) =>
      _authGateway.sendPasswordResetEmail(email);
}
