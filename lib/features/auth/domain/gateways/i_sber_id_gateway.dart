import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';

/// Контракт для авторизации через Sber ID (нативный SDK).
abstract interface class ISberIdGateway {
  /// Начать OAuth-флоу Sber ID через нативное приложение.
  ///
  /// Возвращает [SberIdUserEntity] при успехе, `null` при ошибке или отмене.
  Future<SberIdUserEntity?> signInWithSberId();

  /// Проверить, доступен ли Sber ID на устройстве.
  bool get isSberIdAvailable;
}
