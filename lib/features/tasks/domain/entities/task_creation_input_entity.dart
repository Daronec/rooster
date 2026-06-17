import 'package:rooster/features/tasks/domain/entities/task_entity.dart'
    show TaskEntity;
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_weekday_mask_entity.dart'
    show TaskWeekdayMaskEntity;

/// Снимок полей формы «создание задачи» без зависимостей от Flutter.
///
/// Используется для сборки [TaskEntity] в доменном слое.
final class TaskCreationInputEntity {
  /// Создаёт входные данные.
  const TaskCreationInputEntity({
    required this.title,
    required this.description,
    required this.listId,
    this.parentTaskId,
    this.ownerUserId,
    this.ownerNameSnapshot = '',
    this.executorUserId,
    this.executorTeamId,
    this.observerUserId,
    this.observerTeamId,
    this.dueDateOnly,
    this.isAllDay = true,
    this.startAt,
    this.endAt,
    this.reminderPreset = TaskReminderPresetEntity.none,
    this.customReminderAt,
    this.recurrenceWeekdaysMask = 0,
    this.recurrenceReminderMinutesFromMidnight,
    this.importance = 3,
    this.complexity = 3,
    this.priority = TaskPriorityEntity.normal,
    this.tags = const [],
    this.imageAttachments = const [],
    this.estimatedCost = 0,
    this.materialRequirements = const [],
    this.dependencyTaskIds = const [],
  });

  /// Заголовок (обязателен для сохранения).
  final String title;

  /// Описание.
  final String description;

  /// Идентификатор списка задач.
  final String listId;

  /// Id родительской задачи (если это подзадача).
  final String? parentTaskId;

  /// Id владельца задачи.
  ///
  /// `null` — владелец неизвестен.
  final String? ownerUserId;

  /// Имя владельца для отображения.
  ///
  /// Пустая строка — имя неизвестно.
  final String ownerNameSnapshot;

  /// Id выбранного исполнителя из команд Appwrite.
  ///
  /// `null` — исполнитель не выбран.
  final String? executorUserId;

  /// Id команды Appwrite, из которой выбран исполнитель.
  ///
  /// `null` — исполнитель не выбран.
  final String? executorTeamId;

  /// Id выбранного наблюдателя из команд Appwrite.
  ///
  /// `null` — наблюдатель не выбран.
  final String? observerUserId;

  /// Id команды Appwrite, из которой выбран наблюдатель.
  ///
  /// `null` — наблюдатель не выбран.
  final String? observerTeamId;

  /// Дата срока для режима «весь день» (без времени).
  final DateTime? dueDateOnly;

  /// Весь день: срок задаётся только [dueDateOnly].
  final bool isAllDay;

  /// Начало интервала исполнения (для режима со временем).
  final DateTime? startAt;

  /// Окончание интервала исполнения.
  final DateTime? endAt;

  /// Пресет напоминания.
  final TaskReminderPresetEntity reminderPreset;

  /// Дата/время для пресета [TaskReminderPresetEntity.custom].
  final DateTime? customReminderAt;

  /// Маска дней недели ([TaskWeekdayMaskEntity]); 0 — постоянное напоминание выключено.
  final int recurrenceWeekdaysMask;

  /// Время постоянного напоминания (минуты от полуночи), если задана маска дней.
  final int? recurrenceReminderMinutesFromMidnight;

  /// Важность 1–5 (движок решений).
  final int importance;

  /// Сложность / усилие 1–5 (движок решений).
  final int complexity;

  /// Приоритет.
  final TaskPriorityEntity priority;

  /// Теги.
  final List<String> tags;

  /// Изображения задачи (локальные пути + опциональные URL).
  final List<TaskImageAttachmentEntity> imageAttachments;

  /// Оценочная стоимость выполнения (неотрицательное число; валюта задаётся в UI).
  final double estimatedCost;

  /// Потребность в материалах (как в [TaskEntity.materialRequirements]).
  final List<TaskMaterialRequirementEntity> materialRequirements;

  /// Id задач, от выполнения которых зависит текущая задача.
  final List<String> dependencyTaskIds;

  /// Копия с заменой отдельных полей (например путь после копирования в хранилище приложения).
  TaskCreationInputEntity copyWith({
    String? title,
    String? description,
    String? listId,
    String? parentTaskId,
    String? ownerUserId,
    String? ownerNameSnapshot,
    String? executorUserId,
    String? executorTeamId,
    String? observerUserId,
    String? observerTeamId,
    DateTime? dueDateOnly,
    bool? isAllDay,
    DateTime? startAt,
    DateTime? endAt,
    TaskReminderPresetEntity? reminderPreset,
    DateTime? customReminderAt,
    int? recurrenceWeekdaysMask,
    int? recurrenceReminderMinutesFromMidnight,
    int? importance,
    int? complexity,
    TaskPriorityEntity? priority,
    List<String>? tags,
    List<TaskImageAttachmentEntity>? imageAttachments,
    double? estimatedCost,
    List<TaskMaterialRequirementEntity>? materialRequirements,
    List<String>? dependencyTaskIds,
  }) {
    return TaskCreationInputEntity(
      title: title ?? this.title,
      description: description ?? this.description,
      listId: listId ?? this.listId,
      parentTaskId: parentTaskId ?? this.parentTaskId,
      ownerUserId: ownerUserId ?? this.ownerUserId,
      ownerNameSnapshot: ownerNameSnapshot ?? this.ownerNameSnapshot,
      executorUserId: executorUserId ?? this.executorUserId,
      executorTeamId: executorTeamId ?? this.executorTeamId,
      observerUserId: observerUserId ?? this.observerUserId,
      observerTeamId: observerTeamId ?? this.observerTeamId,
      dueDateOnly: dueDateOnly ?? this.dueDateOnly,
      isAllDay: isAllDay ?? this.isAllDay,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      reminderPreset: reminderPreset ?? this.reminderPreset,
      customReminderAt: customReminderAt ?? this.customReminderAt,
      recurrenceWeekdaysMask:
          recurrenceWeekdaysMask ?? this.recurrenceWeekdaysMask,
      recurrenceReminderMinutesFromMidnight:
          recurrenceReminderMinutesFromMidnight ??
          this.recurrenceReminderMinutesFromMidnight,
      importance: importance ?? this.importance,
      complexity: complexity ?? this.complexity,
      priority: priority ?? this.priority,
      tags: tags ?? this.tags,
      imageAttachments: imageAttachments ?? this.imageAttachments,
      estimatedCost: estimatedCost ?? this.estimatedCost,
      materialRequirements: materialRequirements ?? this.materialRequirements,
      dependencyTaskIds: dependencyTaskIds ?? this.dependencyTaskIds,
    );
  }
}
