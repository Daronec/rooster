import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/core/sync/sync_operation.dart';

/// Исполнитель «без облака»: помечает операции выполненными локально.
///
/// Используется при отсутствии облачного исполнителя синхронизации (например Appwrite + локальная очередь):
/// операции считаются выполненными локально.
final class LocalOnlySyncExecutor implements ISyncRemoteExecutor {
  /// Создаёт исполнитель.
  const LocalOnlySyncExecutor();

  @override
  Future<Result<void, Failure<Exception>>> execute(SyncOperation operation) async {
    return const Result.ok(null);
  }
}
