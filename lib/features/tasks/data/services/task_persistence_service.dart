import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/features/tasks/data/mappers/task_entity_codec.dart';
import 'package:rooster/features/tasks/data/storage/tasks_hive_box_reader.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';
import 'package:rooster/features/tasks/domain/services/task_remote_merge_policy.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:uuid/uuid.dart';

/// {@template task_persistence_service.class}
/// Сервис персистентности задач — только Hive CRUD + постановка в sync queue.
///
/// Выделен из [TasksRepositoryImpl] для соблюдения Single Responsibility Principle:
/// ответственность за хранение и синхронизацию отделена от бизнес-логики
/// (analytics, reminders, change history, image upload).
/// {@endtemplate}
final class TaskPersistenceService {
  /// {@macro task_persistence_service.class}
  TaskPersistenceService({
    required Box<dynamic> tasksBox,
    required ISyncQueue syncQueue,
    required SyncManagerRef syncManagerRef,
    required Uuid uuid,
  })  : _box = tasksBox,
        _syncQueue = syncQueue,
        _syncManagerRef = syncManagerRef,
        _uuid = uuid;

  final Box<dynamic> _box;
  final ISyncQueue _syncQueue;
  final SyncManagerRef _syncManagerRef;
  final Uuid _uuid;

  /// Box для задач (нужен для Hive watch в watchTasks).
  Box<dynamic> get box => _box;

  /// Загрузить задачу по id.
  Future<TaskEntity?> loadTask(String taskId) async {
    final raw = _box.get(taskId);
    if (raw is! Map) {
      return null;
    }
    return TaskEntityCodec.fromMap(Map<String, dynamic>.from(raw));
  }

  /// Загрузить все задачи, отсортированные по updatedAtMillis убыванию.
  Future<List<TaskEntity>> loadAllSortedByUpdatedDesc() {
    return Future.value(TasksHiveBoxReader.readAllSortedByUpdatedDesc(_box));
  }

  /// Загрузить все задачи как Map по id.
  Future<Map<String, TaskEntity>> loadAllAsMapById() {
    return Future.value(TasksHiveBoxReader.readAllAsMapById(_box));
  }

  /// Сохранить задачу локально и поставить в sync queue.
  Future<void> saveTaskLocally(TaskEntity task) async {
    await _box.put(task.id, TaskEntityCodec.toMap(task));
    await _enqueueOperation(
      type: SyncOperationType.upsertTask,
      payload: {'taskId': task.id},
    );
    await _syncManagerRef.scheduleSync();
  }

  /// Удалить задачу локально и поставить delete в sync queue.
  Future<void> deleteTaskLocally(String taskId) async {
    await _box.delete(taskId);
    await _enqueueOperation(
      type: SyncOperationType.deleteTask,
      payload: {'taskId': taskId},
    );
    await _syncManagerRef.scheduleSync();
  }

  /// Заменить локальную задачу, если удалённая новее (без постановки в queue).
  Future<void> mergeRemoteTaskIfNewer(TaskEntity remote) async {
    final local = await loadTask(remote.id);
    if (!TaskRemoteMergePolicy.remoteTaskWins(local: local, remote: remote)) {
      return;
    }
    final merged = remote.copyWith(syncState: TaskSyncStateEntity.synced);
    await _box.put(remote.id, TaskEntityCodec.toMap(merged));
  }

  /// Выставить syncState = synced без новой операции в очереди.
  Future<void> markTaskSyncedAfterRemotePush(String taskId) async {
    final task = await loadTask(taskId);
    if (task == null) {
      return;
    }
    if (task.syncState == TaskSyncStateEntity.synced) {
      return;
    }
    final updated = task.copyWith(syncState: TaskSyncStateEntity.synced);
    await _box.put(taskId, TaskEntityCodec.toMap(updated));
  }

  Future<void> _enqueueOperation({
    required SyncOperationType type,
    required Map<String, dynamic> payload,
  }) async {
    final op = SyncOperation(
      id: _uuid.v4(),
      type: type,
      payload: payload,
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);
  }
}
