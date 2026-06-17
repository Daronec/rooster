import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/tasks/data/mappers/task_list_entity_codec.dart';
import 'package:rooster/features/tasks/domain/default_task_list_constants.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/services/task_remote_merge_policy.dart';
import 'package:uuid/uuid.dart';

/// Локальные списки задач + синхронизация.
final class TaskListsRepositoryImpl implements ITaskListsRepository {
  /// Создаёт репозиторий.
  TaskListsRepositoryImpl({
    required Box<dynamic> listsBox,
    required ISyncQueue syncQueue,
    required SyncManagerRef syncManagerRef,
    required Uuid uuid,
  })  : _box = listsBox,
        _syncQueue = syncQueue,
        _syncManagerRef = syncManagerRef,
        _uuid = uuid;

  final Box<dynamic> _box;
  final ISyncQueue _syncQueue;
  final SyncManagerRef _syncManagerRef;
  final Uuid _uuid;

  /// Для облачного [ISyncRemoteExecutor].
  Future<TaskListEntity?> loadListById(String listId) => loadList(listId);

  @override
  Future<TaskListEntity?> loadList(String listId) async {
    final raw = _box.get(listId);
    if (raw is! Map) {
      return null;
    }
    return TaskListEntityCodec.fromMap(
      Map<String, dynamic>.from(raw),
    );
  }

  List<TaskListEntity> _readAll() {
    final out = <TaskListEntity>[];
    for (final key in _box.keys) {
      final raw = _box.get(key);
      if (raw is Map) {
        out.add(
          TaskListEntityCodec.fromMap(
            Map<String, dynamic>.from(raw),
          ),
        );
      }
    }
    out.sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
    return out;
  }

  /// Если хранилище списков пусто (первая установка или сброс), создаёт список по умолчанию.
  Future<void> _ensureDefaultListWhenStorageEmpty() async {
    if (_readAll().isNotEmpty) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    await saveList(
      TaskListEntity(
        id: kDefaultTaskListId,
        name: kDefaultTaskListDisplayName,
        colorArgb: 0xFF6200EE,
        updatedAtMillis: now,
      ),
    );
  }

  @override
  Stream<List<TaskListEntity>> watchLists() async* {
    await _ensureDefaultListWhenStorageEmpty();
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  @override
  Future<void> saveList(TaskListEntity list) async {
    await _box.put(list.id, TaskListEntityCodec.toMap(list));
    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.upsertTaskList,
      payload: {'listId': list.id},
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<void> deleteList(String listId) async {
    await _box.delete(listId);
    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.deleteTaskList,
      payload: {'listId': listId},
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<void> mergeRemoteListIfNewer(TaskListEntity remote) async {
    final local = await loadList(remote.id);
    if (!TaskRemoteMergePolicy.remoteListWins(local: local, remote: remote)) {
      return;
    }
    await _box.put(remote.id, TaskListEntityCodec.toMap(remote));
  }
}
