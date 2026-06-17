import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/core/sync/sync_operation.dart';

/// Заглушка: облачная синхронизация через Firebase отключена (см. [pubspec.yaml]).
final class FirebaseTaskSyncExecutor implements ISyncRemoteExecutor {
  /// Создаёт заглушку.
  const FirebaseTaskSyncExecutor();

  @override
  Future<Result<void, Failure<Exception>>> execute(
    SyncOperation operation,
  ) async =>
      const Result.ok(null);
}
