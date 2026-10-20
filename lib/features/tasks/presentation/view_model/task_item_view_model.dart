import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';

/// {@template task_item_view_model.class}
/// Минимальный ViewModel-снимок задачи для презентационного слоя.
///
/// Изолирует domain-слой от UI: экраны работают со стабильным
/// DTO-подобным классом, а не с [TaskEntity] (30+ полей,
/// syncState, contentRevision, ownerUserId и т.д.).
///
/// При изменении доменной модели достаточно обновить один
/// маппинг [TaskItemViewModel.fromEntity], а не все экраны.
/// {@endtemplate}
final class TaskItemViewModel {
  /// {@macro task_item_view_model.class}
  const TaskItemViewModel({
    required this.id,
    required this.listId,
    required this.title,
    required this.isPinned,
    required this.priority,
    required this.status,
    required this.dueAt,
    required this.tags,
    required this.updatedAtMillis,
  });

  /// Stable UUID задачи.
  final String id;

  /// Id родительского списка задач.
  final String listId;

  /// Заголовок задачи.
  final String title;

  /// Закреплена ли задача сверху списка.
  final bool isPinned;

  /// Приоритет задачи.
  final TaskPriorityEntity priority;

  /// Статус задачи.
  final TaskStatusEntity status;

  /// Дата и время выполнения (дедлайн).
  final DateTime? dueAt;

  /// Теги задачи.
  final List<String> tags;

  /// Timestamp последнего обновления (millisecondsSinceEpoch).
  final int updatedAtMillis;

  /// Создаёт ViewModel из [TaskEntity].
  ///
  /// Преобразуется только минимальный набор полей, необходимых
  /// для отображения в UI (список задач, чипы, меню).
  factory TaskItemViewModel.fromEntity(TaskEntity entity) {
    return TaskItemViewModel(
      id: entity.id,
      listId: entity.listId,
      title: entity.title,
      isPinned: entity.isPinned,
      priority: entity.priority,
      status: entity.status,
      dueAt: entity.dueAt,
      tags: entity.tags,
      updatedAtMillis: entity.updatedAtMillis,
    );
  }

  /// Преобразует ViewModel обратно в [TaskEntity].
  ///
  /// Используется при сохранении изменений, полученных из UI.
  TaskEntity toEntity() {
    return TaskEntity(
      id: id,
      listId: listId,
      title: title,
      isPinned: isPinned,
      priority: priority,
      status: status,
      dueAt: dueAt,
      tags: tags,
      updatedAtMillis: updatedAtMillis,
      // Поля ниже заполняются вызывающим кодом при необходимости.
      description: '',
      parentTaskId: null,
      ownerUserId: null,
      ownerNameSnapshot: '',
      executorUserId: null,
      executorTeamId: null,
      observerUserId: null,
      observerTeamId: null,
      importance: 0,
      complexity: 0,
      estimatedCost: 0.0,
      materialRequirements: const [],
      dependencyTaskIds: const [],
      reminderOffsetMinutes: null,
      reminderPreset: TaskReminderPresetEntity.none,
      customReminderAt: null,
      recurrenceWeekdaysMask: 0,
      recurrenceReminderMinutesFromMidnight: 0,
      imageAttachments: const [],
      contentRevision: 0,
      syncState: TaskSyncStateEntity.synced,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskItemViewModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          listId == other.listId &&
          title == other.title &&
          isPinned == other.isPinned &&
          priority == other.priority &&
          status == other.status &&
          dueAt == other.dueAt &&
          _listsEqual(tags, other.tags) &&
          updatedAtMillis == other.updatedAtMillis;

  @override
  int get hashCode =>
      id.hashCode ^
      listId.hashCode ^
      title.hashCode ^
      isPinned.hashCode ^
      priority.hashCode ^
      status.hashCode ^
      dueAt.hashCode ^
      _listHashCode(tags) ^
      updatedAtMillis.hashCode;

  static bool _listsEqual(List<String>? a, List<String>? b) {
    if (a == null || b == null) {
      return a == b;
    }
    return _listEquals(a, b);
  }

  static int _listHashCode(List<String> list) {
    var hash = 0;
    for (final item in list) {
      hash = (hash * 31) + item.hashCode;
    }
    return hash;
  }

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
}
