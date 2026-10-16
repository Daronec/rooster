import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';

/// Минимальный шлюз сессии: состояние пользователя и выход.
///
/// Используется для проверки авторизации и навигационных гвардов.
/// Основная авторизация происходит через [IVkIdGateway] / [IYandexIdGateway].
abstract interface class IAuthGateway {
  /// Поток смены пользователя.
  Stream<AppAuthUserEntity?> get authStateChanges;

  /// Текущий пользователь (null если не авторизован).
  AppAuthUserEntity? get currentUser;

  /// Выйти из сессии.
  Future<void> signOut();
}
