import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Доступ к задачам: локальный SSOT + постановка в sync queue.
abstract interface class ITasksRepository {
  /// Наблюдение за всеми задачами (Hive → UI).
  Stream<List<TaskEntity>> watchTasks();

  /// Одна задача по id; null, если записи нет.
  Future<TaskEntity?> loadTask(String taskId);

  /// Сохранить или обновить локально и поставить в очередь синхронизации.
  Future<void> saveTask(TaskEntity task);

  /// Удалить локально и поставить delete в очередь.
  Future<void> deleteTask(String taskId);

  /// Входящая синхронизация: заменить локальную задачу, если снимок с облака новее; без постановки в sync queue.
  Future<void> mergeRemoteTaskIfNewer(TaskEntity remote);

  /// После успешного upsert в облако: выставить состояние «синхронизировано» без новой операции в очереди.
  Future<void> markTaskSyncedAfterRemotePush(String taskId);
}
