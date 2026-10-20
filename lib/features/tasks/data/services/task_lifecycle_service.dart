import 'package:rooster/core/analytics/i_app_analytics_gateway.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/features/tasks/data/repositories/task_image_upload_enqueue_stub.dart'
    if (dart.library.io) 'package:rooster/features/tasks/data/repositories/task_image_upload_enqueue_io.dart'
    as task_image_upload_enqueue;
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_change_author_provider.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_due_reminder_gateway.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_change_history_repository.dart';
import 'package:uuid/uuid.dart';

/// {@template task_lifecycle_service.class}
/// Сервис жизненного цикла задач — побочные эффекты при CRUD.
///
/// Инкапсулирует:
/// - Analytics (метрики создания/удаления)
/// - Reminders (напоминания по дедлайну)
/// - Change history (аудит изменений)
/// - Image upload (очередь загрузки вложений)
/// {@endtemplate}
final class TaskLifecycleService {
  /// {@macro task_lifecycle_service.class}
  TaskLifecycleService({
    IAppAnalyticsGateway? analytics,
    ITaskDueReminderGateway? dueReminderGateway,
    ITaskChangeHistoryWriter? taskChangeHistoryWriter,
    ITaskChangeAuthorProvider? taskChangeAuthorProvider,
    required SyncManagerRef syncManagerRef,
    required Uuid uuid,
    required ISyncQueue syncQueue,
  })  : _analytics = analytics,
        _dueReminderGateway = dueReminderGateway,
        _taskChangeHistoryWriter = taskChangeHistoryWriter,
        _taskChangeAuthorProvider = taskChangeAuthorProvider,
        _syncManagerRef = syncManagerRef,
        _uuid = uuid,
        _syncQueue = syncQueue;

  final IAppAnalyticsGateway? _analytics;
  final ITaskDueReminderGateway? _dueReminderGateway;
  final ITaskChangeHistoryWriter? _taskChangeHistoryWriter;
  final ITaskChangeAuthorProvider? _taskChangeAuthorProvider;
  final SyncManagerRef _syncManagerRef;
  final Uuid _uuid;
  final ISyncQueue _syncQueue;

  @override
  Future<void> onTaskCreated(TaskEntity task) async {
    await _upsertReminder(task);
    await _writeChange(task, TaskChangeKindEntity.created);
    await _enqueueImageUpload(task);
    await _logCreateAnalytics(task);
    await _scheduleSync();
  }

  @override
  Future<void> onTaskUpdated(TaskEntity task, TaskEntity? previous) async {
    if (previous == null) {
      // Не найдена — считаем созданием
      await onTaskCreated(task);
      return;
    }

    await _upsertReminder(task);
    final changedFields = _changedFields(previous, task);
    if (changedFields.isNotEmpty) {
      await _writeChange(task, TaskChangeKindEntity.updated, changedFields);
    }
    await _enqueueImageUpload(task);
    await _logUpdateAnalytics(task);
    await _scheduleSync();
  }

  @override
  Future<void> onTaskDeleted(TaskEntity task) async {
    await _cancelReminder(task.id);
    await _writeChangeDeleted(task);
    await _logDeleteAnalytics();
    await _scheduleSync();
  }

  Future<void> _upsertReminder(TaskEntity task) async {
    final gateway = _dueReminderGateway;
    if (gateway != null) {
      await gateway.upsertDueReminder(task);
    }
  }

  Future<void> _cancelReminder(String taskId) async {
    final gateway = _dueReminderGateway;
    if (gateway != null) {
      await gateway.cancelDueReminder(taskId);
    }
  }

  Future<void> _writeChange(
    TaskEntity task,
    TaskChangeKindEntity kind, [
    List<TaskChangeFieldEntity> fields = const [],
  ]) async {
    final writer = _taskChangeHistoryWriter;
    if (writer == null) {
      return;
    }
    await writer.addChange(
      TaskChangeEntity(
        id: _uuid.v4(),
        taskId: task.id,
        kind: kind,
        changedAtMillis: DateTime.now().millisecondsSinceEpoch,
        changedFields: fields,
        taskTitleSnapshot: task.title,
        authorNameSnapshot: _resolveAuthorName(),
      ),
    );
  }

  Future<void> _writeChangeDeleted(TaskEntity task) async {
    final writer = _taskChangeHistoryWriter;
    if (writer == null) {
      return;
    }
    await writer.addChange(
      TaskChangeEntity(
        id: _uuid.v4(),
        taskId: task.id,
        kind: TaskChangeKindEntity.deleted,
        changedAtMillis: DateTime.now().millisecondsSinceEpoch,
        changedFields: const <TaskChangeFieldEntity>[],
        taskTitleSnapshot: task.title,
        authorNameSnapshot: _resolveAuthorName(),
      ),
    );
  }

  Future<void> _enqueueImageUpload(TaskEntity task) async {
    await task_image_upload_enqueue.enqueueTaskImageUploadIfNeeded(
      task: task,
      syncQueue: _syncQueue,
      syncManagerRef: _syncManagerRef,
      uuid: _uuid,
    );
  }

  Future<void> _logCreateAnalytics(TaskEntity task) async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    await analytics.logCreateTask();
    if (task.status == TaskStatusEntity.completed) {
      await analytics.logCompleteTask();
    }
  }

  Future<void> _logUpdateAnalytics(TaskEntity task) async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    if (task.status == TaskStatusEntity.completed) {
      await analytics.logCompleteTask();
    }
  }

  Future<void> _logDeleteAnalytics() async {
    final analytics = _analytics;
    if (analytics == null) {
      return;
    }
    await analytics.logDeleteTask();
  }

  Future<void> _scheduleSync() async {
    await _syncManagerRef.scheduleSync();
  }

  String _resolveAuthorName() {
    final name = _taskChangeAuthorProvider?.currentAuthorName?.trim();
    return name != null && name.isNotEmpty ? name : '';
  }

  List<TaskChangeFieldEntity> _changedFields(
    TaskEntity previous,
    TaskEntity updated,
  ) {
    final fields = <TaskChangeFieldEntity>[];

    if (previous.title != updated.title) {
      fields.add(TaskChangeFieldEntity.title);
    }
    if (previous.description != updated.description) {
      fields.add(TaskChangeFieldEntity.description);
    }
    if (previous.listId != updated.listId) {
      fields.add(TaskChangeFieldEntity.list);
    }
    if (previous.parentTaskId != updated.parentTaskId) {
      fields.add(TaskChangeFieldEntity.parentTask);
    }
    if (previous.executorUserId != updated.executorUserId ||
        previous.executorTeamId != updated.executorTeamId) {
      fields.add(TaskChangeFieldEntity.executor);
    }
    if (previous.observerUserId != updated.observerUserId ||
        previous.observerTeamId != updated.observerTeamId) {
      fields.add(TaskChangeFieldEntity.observer);
    }
    if (_millisOrNull(previous.dueAt) != _millisOrNull(updated.dueAt) ||
        previous.isAllDay != updated.isAllDay) {
      fields.add(TaskChangeFieldEntity.dueDate);
    }
    if (_millisOrNull(previous.startAt) != _millisOrNull(updated.startAt) ||
        _millisOrNull(previous.endAt) != _millisOrNull(updated.endAt)) {
      fields.add(TaskChangeFieldEntity.time);
    }
    if (previous.priority != updated.priority) {
      fields.add(TaskChangeFieldEntity.priority);
    }
    if (!_listEquals(previous.tags, updated.tags)) {
      fields.add(TaskChangeFieldEntity.tags);
    }
    if (previous.status != updated.status) {
      fields.add(TaskChangeFieldEntity.status);
    }
    if (previous.estimatedCost != updated.estimatedCost) {
      fields.add(TaskChangeFieldEntity.estimatedCost);
    }
    if (!_materialsEquals(previous, updated)) {
      fields.add(TaskChangeFieldEntity.materials);
    }
    if (!_attachmentsEquals(previous.imageAttachments, updated.imageAttachments)) {
      fields.add(TaskChangeFieldEntity.attachment);
    }

    return fields;
  }

  static int? _millisOrNull(DateTime? dateTime) => dateTime?.millisecondsSinceEpoch;

  static bool _listEquals(List<String> a, List<String> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _materialsEquals(TaskEntity a, TaskEntity b) {
    final aRows = a.materialRequirements;
    final bRows = b.materialRequirements;
    if (aRows.length != bRows.length) return false;
    for (var i = 0; i < aRows.length; i++) {
      final left = aRows[i];
      final right = bRows[i];
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
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      final left = a[i];
      final right = b[i];
      if (left.localPath != right.localPath || left.remoteUrl != right.remoteUrl) {
        return false;
      }
    }
    return true;
  }
}
