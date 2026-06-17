import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart'
    show TaskListEntity;
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';

/// Задача: доменная модель для UI и правил offline-first.
///
/// [TaskStatusEntity] — факт выполнения (pending / completed / archived).
/// Поля важности/приоритета/стоимости/зависимостей — вход для движка выполнимости
/// ([TaskFeasibilityStatusEntity] считается отдельно, не дублирует статус выполнения).
final class TaskEntity {
  /// Создаёт задачу.
  const TaskEntity({
    required this.id,
    required this.listId,
    required this.title,
    required this.updatedAtMillis,
    this.parentTaskId,
    this.ownerUserId,
    this.ownerNameSnapshot = '',
    this.executorUserId,
    this.executorTeamId,
    this.observerUserId,
    this.observerTeamId,
    this.isPinned = false,
    this.importance = 3,
    this.complexity = 3,
    this.estimatedCost = 0,
    this.materialRequirements = const [],
    this.dependencyTaskIds = const [],
    this.description = '',
    this.dueAt,
    this.isAllDay = false,
    this.startAt,
    this.endAt,
    this.durationMinutes,
    this.reminderOffsetMinutes,
    this.reminderPreset = TaskReminderPresetEntity.none,
    this.customReminderAt,
    this.priority = TaskPriorityEntity.normal,
    this.tags = const [],
    this.recurrenceWeekdaysMask = 0,
    this.recurrenceReminderMinutesFromMidnight,
    this.imageAttachments = const [],
    this.status = TaskStatusEntity.pending,
    this.contentRevision = 0,
    this.syncState = TaskSyncStateEntity.pendingSync,
  });

  /// Стабильный id (UUID).
  final String id;

  /// Id списка ([TaskListEntity]).
  final String listId;

  /// Id родительской задачи (если это подзадача).
  final String? parentTaskId;

  /// Id владельца задачи.
  ///
  /// `null` — владелец неизвестен для старых локальных задач.
  final String? ownerUserId;

  /// Имя владельца на момент создания/первого сохранения.
  ///
  /// Используется для отображения чужих задач без дополнительного запроса профиля.
  final String ownerNameSnapshot;

  /// Id пользователя-исполнителя из команд Appwrite.
  ///
  /// `null` — исполнитель не выбран.
  final String? executorUserId;

  /// Id команды Appwrite, из которой выбран исполнитель.
  ///
  /// `null` — исполнитель не выбран.
  final String? executorTeamId;

  /// Id пользователя-наблюдателя из команд Appwrite.
  ///
  /// `null` — наблюдатель не выбран.
  final String? observerUserId;

  /// Id команды Appwrite, из которой выбран наблюдатель.
  ///
  /// `null` — наблюдатель не выбран.
  final String? observerTeamId;

  /// Закрепление задачи вверху экрана списка задач.
  final bool isPinned;

  /// Заголовок.
  final String title;

  /// Важность 1–5 (движок принятия решений).
  final int importance;

  /// Сложность / усилие 1–5.
  final int complexity;

  /// Оценочная стоимость в деньгах (валюта задаётся на уровне UI).
  final double estimatedCost;

  /// Потребность в материалах: название, количество, стоимость строки; опционально связь со складом.
  final List<TaskMaterialRequirementEntity> materialRequirements;

  /// Id задач-предшественников (задача не ready, пока все не completed).
  final List<String> dependencyTaskIds;

  /// Описание.
  final String description;

  /// Срок; null — без даты.
  final DateTime? dueAt;

  /// Весь день.
  final bool isAllDay;

  /// Начало интервала исполнения (если не [isAllDay]).
  final DateTime? startAt;

  /// Окончание интервала исполнения.
  final DateTime? endAt;

  /// Длительность в минутах; null если не задана.
  final int? durationMinutes;

  /// Напоминание за N минут до срока (агрегат для уведомлений и обратной совместимости).
  final int? reminderOffsetMinutes;

  /// Выбранный пресет напоминания.
  final TaskReminderPresetEntity reminderPreset;

  /// Произвольная дата/время напоминания при пресете [TaskReminderPresetEntity.custom].
  final DateTime? customReminderAt;

  /// Приоритет.
  final TaskPriorityEntity priority;

  /// Теги.
  final List<String> tags;

  /// Битовая маска дней недели для постоянного напоминания.
  final int recurrenceWeekdaysMask;

  /// Время постоянного напоминания (минуты от полуночи).
  final int? recurrenceReminderMinutesFromMidnight;

  /// Вложения изображений задачи.
  final List<TaskImageAttachmentEntity> imageAttachments;

  /// Статус.
  final TaskStatusEntity status;

  /// Монотонная ревизия контента (конфликты / merge).
  final int contentRevision;

  /// Время последнего изменения (epoch ms).
  final int updatedAtMillis;

  /// Состояние синхронизации.
  final TaskSyncStateEntity syncState;

  /// Копия с заменой полей.
  TaskEntity copyWith({
    String? parentTaskId,
    String? ownerUserId,
    String? ownerNameSnapshot,
    String? executorUserId,
    String? executorTeamId,
    String? observerUserId,
    String? observerTeamId,
    bool? isPinned,
    int? importance,
    int? complexity,
    double? estimatedCost,
    List<TaskMaterialRequirementEntity>? materialRequirements,
    List<String>? dependencyTaskIds,
    String? title,
    String? description,
    DateTime? dueAt,
    bool? isAllDay,
    DateTime? startAt,
    DateTime? endAt,
    int? durationMinutes,
    int? reminderOffsetMinutes,
    TaskReminderPresetEntity? reminderPreset,
    DateTime? customReminderAt,
    TaskPriorityEntity? priority,
    List<String>? tags,
    int? recurrenceWeekdaysMask,
    int? recurrenceReminderMinutesFromMidnight,
    List<TaskImageAttachmentEntity>? imageAttachments,
    TaskStatusEntity? status,
    int? contentRevision,
    int? updatedAtMillis,
    TaskSyncStateEntity? syncState,
  }) {
    return TaskEntity(
      id: id,
      listId: listId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerNameSnapshot: ownerNameSnapshot ?? this.ownerNameSnapshot,
      executorUserId: executorUserId ?? this.executorUserId,
      executorTeamId: executorTeamId ?? this.executorTeamId,
      observerUserId: observerUserId ?? this.observerUserId,
      observerTeamId: observerTeamId ?? this.observerTeamId,
      isPinned: isPinned ?? this.isPinned,
      title: title ?? this.title,
      importance: importance ?? this.importance,
      complexity: complexity ?? this.complexity,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      materialRequirements: materialRequirements ?? this.materialRequirements,
      dependencyTaskIds: dependencyTaskIds ?? this.dependencyTaskIds,
      description: description ?? this.description,
      dueAt: dueAt ?? this.dueAt,
      isAllDay: isAllDay ?? this.isAllDay,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      reminderOffsetMinutes:
          reminderOffsetMinutes ?? this.reminderOffsetMinutes,
      reminderPreset: reminderPreset ?? this.reminderPreset,
      customReminderAt: customReminderAt ?? this.customReminderAt,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      recurrenceWeekdaysMask:
          recurrenceWeekdaysMask ?? this.recurrenceWeekdaysMask,
      recurrenceReminderMinutesFromMidnight:
          recurrenceReminderMinutesFromMidnight ??
          this.recurrenceReminderMinutesFromMidnight,
      imageAttachments: imageAttachments ?? this.imageAttachments,
      status: status ?? this.status,
      contentRevision: contentRevision ?? this.contentRevision,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      syncState: syncState ?? this.syncState,
    );
  }
}
