import 'package:rooster/features/tasks/data/services/task_lifecycle_service.dart';
import 'package:rooster/features/tasks/data/services/task_persistence_service.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// {@template tasks_repository_impl.class}
/// Hive как SSOT + постановка операций в [ISyncQueue].
///
/// Инкапсулирует только координирование между [TaskPersistenceService]
/// (хранение + sync queue) и [TaskLifecycleService] (side effects).
/// {@endtemplate}
final class TasksRepositoryImpl implements ITasksRepository {
  /// {@macro tasks_repository_impl.class}
  TasksRepositoryImpl({
    required TaskPersistenceService persistence,
    required TaskLifecycleService lifecycle,
  })  : _persistence = persistence,
        _lifecycle = lifecycle;

  final TaskPersistenceService _persistence;
  final TaskLifecycleService _lifecycle;

  @override
  Future<TaskEntity?> loadTask(String taskId) => _persistence.loadTask(taskId);

  /// Для облачного [ISyncRemoteExecutor]: загрузить задачу из Hive.
  Future<TaskEntity?> loadTaskById(String taskId) => _persistence.loadTask(taskId);

  @override
  Stream<List<TaskEntity>> watchTasks() async* {
    yield await _persistence.loadAllSortedByUpdatedDesc();
    await for (final _ in _persistence.box.watch()) {
      yield await _persistence.loadAllSortedByUpdatedDesc();
    }
  }

  @override
  Future<void> saveTask(TaskEntity task) async {
    final existing = await _persistence.loadTask(task.id);
    await _persistence.saveTaskLocally(task);
    await _lifecycle.onTaskUpdated(task, existing);
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final existing = await _persistence.loadTask(taskId);
    await _persistence.deleteTaskLocally(taskId);
    if (existing != null) {
      await _lifecycle.onTaskDeleted(existing);
    }
  }

  @override
  Future<void> mergeRemoteTaskIfNewer(TaskEntity remote) async {
    await _persistence.mergeRemoteTaskIfNewer(remote);
  }

  Future<void> markTaskSyncedAfterRemotePush(String taskId) async {
    await _persistence.markTaskSyncedAfterRemotePush(taskId);
  }
}
