import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/sync/sync_operation.dart';

/// Выполнение одной операции на стороне облака (при наличии настроенного бэкенда).
abstract interface class ISyncRemoteExecutor {
  /// Отправка операции; при успехе операция удаляется из очереди вызывающим кодом.
  Future<Result<void, Failure<Exception>>> execute(SyncOperation operation);
}
