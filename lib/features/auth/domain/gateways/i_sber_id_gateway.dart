import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';

/// Контракт для авторизации через Sber ID.
///
/// Используется для запуска OAuth-флоу (через нативное приложение или
/// браузер). Результат авторизации приходит через [IAuthGateway.authStateChanges].
abstract interface class ISberIdGateway {
  /// Начать OAuth-флоу Sber ID.
  ///
  /// Возвращает `null` при ошибке или отмене. При успехе пользователь
  /// появляется в потоке [IAuthGateway.authStateChanges].
  Future<void> signInWithSberId();

  /// Проверить, доступен ли Sber ID на устройстве.
  bool get isSberIdAvailable;

  /// Текущий пользователь (если авторизован через Sber ID).
  AppAuthUserEntity? get currentUser;

  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges;

  /// Выйти из сессии.
  Future<void> signOut();

  /// Освободить ресурсы (stream subscriptions и т.д.).
  void dispose();
}
