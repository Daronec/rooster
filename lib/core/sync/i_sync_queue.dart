import 'package:rooster/core/sync/sync_operation.dart';

/// Персистентная очередь исходящих операций (порт domain/data).
abstract interface class ISyncQueue {
  /// Все операции в порядке FIFO.
  Future<List<SyncOperation>> loadAll();

  /// Добавить в конец.
  Future<void> enqueue(SyncOperation operation);

  /// Удалить после успешной отправки.
  Future<void> remove(String operationId);

  /// Обновить метаданные ретрая.
  Future<void> update(SyncOperation operation);

  /// Поток изменений (для dev-панели).
  Stream<void> get changes;
}
