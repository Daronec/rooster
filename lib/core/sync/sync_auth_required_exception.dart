import 'package:rooster/core/sync/sync_manager_impl.dart' show SyncManagerImpl;
import 'package:rooster/core/sync/sync_operation.dart' show SyncOperation;

/// Удалённый синк невозможен: нет авторизованного пользователя облака.
///
/// [SyncManagerImpl] не увеличивает [SyncOperation.attemptCount] и выходит из
/// цикла обработки до появления сессии.
final class SyncAuthRequiredException implements Exception {
  @override
  String toString() => 'Нет пользователя для синхронизации';
}
