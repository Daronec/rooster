import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/core/analytics/i_app_analytics_gateway.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/tasks/data/mappers/task_entity_codec.dart';
import 'package:rooster/features/tasks/data/storage/tasks_hive_box_reader.dart';
import 'package:rooster/features/tasks/data/repositories/task_image_upload_enqueue_stub.dart'
    if (dart.library.io) 'package:rooster/features/tasks/data/repositories/task_image_upload_enqueue_io.dart'
    as task_image_upload_enqueue;
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_due_reminder_gateway.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_change_history_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/services/task_remote_merge_policy.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_change_author_provider.dart';
import 'package:uuid/uuid.dart';

/// Hive как SSOT + постановка операций в [ISyncQueue].
final class TasksRepositoryImpl implements ITasksRepository {
  /// Создаёт репозиторий.
  TasksRepositoryImpl({
    required Box<dynamic> tasksBox,
    required ISyncQueue syncQueue,
    required SyncManagerRef syncManagerRef,
    required Uuid uuid,
    IAppAnalyticsGateway? analytics,
    ITaskDueReminderGateway? dueReminderGateway,
    ITaskChangeHistoryWriter? taskChangeHistoryWriter,
    ITaskChangeAuthorProvider? taskChangeAuthorProvider,
  }) : _box = tasksBox,
       _syncQueue = syncQueue,
       _syncManagerRef = syncManagerRef,
       _uuid = uuid,
       _analytics = analytics,
       _dueReminderGateway = dueReminderGateway,
       _taskChangeHistoryWriter = taskChangeHistoryWriter,
       _taskChangeAuthorProvider = taskChangeAuthorProvider;

  final Box<dynamic> _box;
  final ISyncQueue _syncQueue;
  final SyncManagerRef _syncManagerRef;
  final Uuid _uuid;
  final IAppAnalyticsGateway? _analytics;
  final ITaskDueReminderGateway? _dueReminderGateway;
  final ITaskChangeHistoryWriter? _taskChangeHistoryWriter;
  final ITaskChangeAuthorProvider? _taskChangeAuthorProvider;

  @override
  Future<TaskEntity?> loadTask(String taskId) => _loadTaskById(taskId);

  /// Для облачного [ISyncRemoteExecutor]: загрузить задачу из Hive.
  Future<TaskEntity?> loadTaskById(String taskId) => _loadTaskById(taskId);

  Future<TaskEntity?> _loadTaskById(String taskId) async {
    final raw = _box.get(taskId);
    if (raw is! Map) {
      return null;
    }
    return TaskEntityCodec.fromMap(Map<String, dynamic>.from(raw));
  }

  List<TaskEntity> _readAll() =>
      TasksHiveBoxReader.readAllSortedByUpdatedDesc(_box);

  @override
  Stream<List<TaskEntity>> watchTasks() async* {
    yield _readAll();
    await for (final _ in _box.watch()) {
      yield _readAll();
    }
  }

  @override
  Future<void> saveTask(TaskEntity task) async {
    final existing = await _loadTaskById(task.id);
    final existed = existing != null;
    await _box.put(task.id, TaskEntityCodec.toMap(task));

    final dueGateway = _dueReminderGateway;
    if (dueGateway != null) {
      await dueGateway.upsertDueReminder(task);
    }

    final historyWriter = _taskChangeHistoryWriter;
    if (historyWriter != null) {
      final kind = existing != null
          ? TaskChangeKindEntity.updated
          : TaskChangeKindEntity.created;
      final fields = existing != null
          ? _changedFields(existing: existing, updated: task)
          : const <TaskChangeFieldEntity>[];
      final shouldWrite =
          kind != TaskChangeKindEntity.updated || fields.isNotEmpty;
      if (shouldWrite) {
        await historyWriter.addChange(
          TaskChangeEntity(
            id: _uuid.v4(),
            taskId: task.id,
            kind: kind,
            changedAtMillis: DateTime.now().millisecondsSinceEpoch,
            changedFields: fields,
            taskTitleSnapshot: task.title,
            authorNameSnapshot: _resolveAuthorNameSnapshot(),
          ),
        );
      }
    }

    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.upsertTask,
      payload: {'taskId': task.id},
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);

    await task_image_upload_enqueue.enqueueTaskImageUploadIfNeeded(
      task: task,
      syncQueue: _syncQueue,
      syncManagerRef: _syncManagerRef,
      uuid: _uuid,
    );

    final analytics = _analytics;
    if (analytics != null) {
      if (!existed) {
        await analytics.logCreateTask();
      }
      if (task.status == TaskStatusEntity.completed) {
        await analytics.logCompleteTask();
      }
    }
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<void> deleteTask(String taskId) async {
    final existing = await _loadTaskById(taskId);
    await _box.delete(taskId);

    final dueGateway = _dueReminderGateway;
    if (dueGateway != null) {
      await dueGateway.cancelDueReminder(taskId);
    }

    final historyWriter = _taskChangeHistoryWriter;
    if (historyWriter != null && existing != null) {
      await historyWriter.addChange(
        TaskChangeEntity(
          id: _uuid.v4(),
          taskId: taskId,
          kind: TaskChangeKindEntity.deleted,
          changedAtMillis: DateTime.now().millisecondsSinceEpoch,
          changedFields: const <TaskChangeFieldEntity>[],
          taskTitleSnapshot: existing.title,
          authorNameSnapshot: _resolveAuthorNameSnapshot(),
        ),
      );
    }

    final op = SyncOperation(
      id: _uuid.v4(),
      type: SyncOperationType.deleteTask,
      payload: {'taskId': taskId},
      createdAtMillis: DateTime.now().millisecondsSinceEpoch,
    );
    await _syncQueue.enqueue(op);
    await _analytics?.logDeleteTask();
    await _syncManagerRef.scheduleSync();
  }

  @override
  Future<void> mergeRemoteTaskIfNewer(TaskEntity remote) async {
    final local = await _loadTaskById(remote.id);
    if (!TaskRemoteMergePolicy.remoteTaskWins(local: local, remote: remote)) {
      return;
    }
    final merged = remote.copyWith(syncState: TaskSyncStateEntity.synced);
    await _box.put(remote.id, TaskEntityCodec.toMap(merged));
    final dueGateway = _dueReminderGateway;
    if (dueGateway != null) {
      await dueGateway.upsertDueReminder(merged);
    }
  }

  @override
  Future<void> markTaskSyncedAfterRemotePush(String taskId) async {
    final task = await _loadTaskById(taskId);
    if (task == null) {
      return;
    }
    if (task.syncState == TaskSyncStateEntity.synced) {
      return;
    }
    await _box.put(
      taskId,
      TaskEntityCodec.toMap(
        task.copyWith(syncState: TaskSyncStateEntity.synced),
      ),
    );
  }

  List<TaskChangeFieldEntity> _changedFields({
    required TaskEntity existing,
    required TaskEntity updated,
  }) {
    final fields = <TaskChangeFieldEntity>[];
    if (existing.title != updated.title) {
      fields.add(TaskChangeFieldEntity.title);
    }
    if (existing.description != updated.description) {
      fields.add(TaskChangeFieldEntity.description);
    }
    if (existing.listId != updated.listId) {
      fields.add(TaskChangeFieldEntity.list);
    }
    if (existing.parentTaskId != updated.parentTaskId) {
      fields.add(TaskChangeFieldEntity.parentTask);
    }
    if (existing.executorUserId != updated.executorUserId ||
        existing.executorTeamId != updated.executorTeamId) {
      fields.add(TaskChangeFieldEntity.executor);
    }
    if (existing.observerUserId != updated.observerUserId ||
        existing.observerTeamId != updated.observerTeamId) {
      fields.add(TaskChangeFieldEntity.observer);
    }
    if (_millisOrNull(existing.dueAt) != _millisOrNull(updated.dueAt) ||
        existing.isAllDay != updated.isAllDay) {
      fields.add(TaskChangeFieldEntity.dueDate);
    }
    if (_millisOrNull(existing.startAt) != _millisOrNull(updated.startAt) ||
        _millisOrNull(existing.endAt) != _millisOrNull(updated.endAt)) {
      fields.add(TaskChangeFieldEntity.time);
    }
    if (existing.priority != updated.priority) {
      fields.add(TaskChangeFieldEntity.priority);
    }
    if (!_listEquals(existing.tags, updated.tags)) {
      fields.add(TaskChangeFieldEntity.tags);
    }
    if (existing.status != updated.status) {
      fields.add(TaskChangeFieldEntity.status);
    }
    if (existing.estimatedCost != updated.estimatedCost) {
      fields.add(TaskChangeFieldEntity.estimatedCost);
    }
    if (!_materialsEquals(existing, updated)) {
      fields.add(TaskChangeFieldEntity.materials);
    }
    if (!_attachmentsEquals(
      existing.imageAttachments,
      updated.imageAttachments,
    )) {
      fields.add(TaskChangeFieldEntity.attachment);
    }
    return fields;
  }

  String _resolveAuthorNameSnapshot() {
    final authorName = _taskChangeAuthorProvider?.currentAuthorName?.trim();
    if (authorName == null || authorName.isEmpty) {
      return '';
    }
    return authorName;
  }

  static int? _millisOrNull(DateTime? dateTime) =>
      dateTime?.millisecondsSinceEpoch;

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      if (a[index] != b[index]) {
        return false;
      }
    }
    return true;
  }

  static bool _materialsEquals(TaskEntity a, TaskEntity b) {
    final aRows = a.materialRequirements;
    final bRows = b.materialRequirements;
    if (aRows.length != bRows.length) {
      return false;
    }
    for (var index = 0; index < aRows.length; index++) {
      final left = aRows[index];
      final right = bRows[index];
      if (left.id != right.id ||
          left.name != right.name ||
          left.requiredQuantity != right.requiredQuantity ||
          left.lineCost != right.lineCost ||
          left.stockItemId != right.stockItemId) {
        return false;
      }
    }
    return true;
  }

  static bool _attachmentsEquals(
    List<TaskImageAttachmentEntity> a,
    List<TaskImageAttachmentEntity> b,
  ) {
    if (identical(a, b)) {
      return true;
    }
    if (a.length != b.length) {
      return false;
    }
    for (var index = 0; index < a.length; index++) {
      final left = a[index];
      final right = b[index];
      if (left.localPath != right.localPath ||
          left.remoteUrl != right.remoteUrl) {
        return false;
      }
    }
    return true;
  }
}
