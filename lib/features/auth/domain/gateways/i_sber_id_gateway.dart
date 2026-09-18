import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';

/// Вход через Sber ID (OAuth2 провайдер).
abstract interface class ISberIdGateway {
  /// Доступен ли вход через Sber ID на текущей платформе.
  bool get isSberIdAvailable;

  /// Вход через Sber ID.
  /// 
  /// Возвращает [SberIdUserEntity] при успехе, `null` при ошибке или отмене.
  Future<SberIdUserEntity?> signInWithSberId();

  /// Выход из сессии Sber ID.
  Future<void> signOut();
}
