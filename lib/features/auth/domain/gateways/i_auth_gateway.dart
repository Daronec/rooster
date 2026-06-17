import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/entities/app_phone_otp_challenge_entity.dart';

/// Вход и сессия: Appwrite или офлайн-заглушка без облака.
abstract interface class IAuthGateway {
  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges;

  /// Текущий пользователь.
  AppAuthUserEntity? get currentUser;

  /// Поддерживается ли вход по email и паролю (зависит от шлюза и продукта).
  bool get supportsEmailPasswordAuth;

  /// Поддерживается ли вход по SMS (код на телефон).
  bool get supportsPhoneOtpAuth;

  /// Доступен ли вход через HUAWEI Account Kit (Android + HMS).
  bool get isHuaweiSignInAvailable;

  /// Вход через Google (OAuth Appwrite на поддерживаемых платформах).
  Future<void> signInWithGoogle();

  /// Вход через Apple (OAuth Appwrite на поддерживаемых платформах).
  Future<void> signInWithApple();

  /// Вход через HUAWEI ID (HMS).
  Future<void> signInWithHuawei();

  /// Анонимная сессия (если шлюз поддерживает; иначе исключение).
  Future<void> signInAnonymously();

  /// Выход из всех провайдеров сессии.
  Future<void> signOut();

  /// Сброс пароля по email (если поддерживается бэкендом).
  Future<void> sendPasswordResetEmail(String email);

  /// Вход существующего пользователя по email и паролю.
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  });

  /// Создание учётной записи по email и паролю.
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  });

  /// Регистрация с именем и телефоном (телефон — после сессии через Appwrite [updatePhone]).
  Future<void> signUpWithEmailPasswordProfile({
    required String email,
    required String password,
    required String name,
    required String phoneE164,
  });

  /// Запросить SMS-код для входа по телефону (E.164, например +79001234567).
  Future<AppPhoneOtpChallengeEntity> startPhoneSignIn({
    required String phoneE164,
  });

  /// Подтвердить вход по телефону кодом из SMS.
  Future<void> completePhoneSignIn({
    required String userId,
    required String otpSecret,
  });
}
