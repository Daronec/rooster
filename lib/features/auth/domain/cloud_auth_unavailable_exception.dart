import 'package:rooster/features/auth/domain/cloud_auth_unavailable_reason.dart';

/// Сигнал для UI: вход намеренно недоступен для текущей ветки (Firebase / HMS).
final class CloudAuthUnavailableException implements Exception {
  /// Создаёт исключение.
  CloudAuthUnavailableException(this.reason);

  /// Причина блокировки.
  final CloudAuthUnavailableReason reason;

  @override
  String toString() => 'CloudAuthUnavailableException($reason)';
}
