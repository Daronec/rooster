import 'package:rooster/features/tasks/domain/entities/task_creation_input_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Преобразование [TaskEntity] в данные формы создания/редактирования.
final class TaskCreationInputFromTaskEntity {
  const TaskCreationInputFromTaskEntity._();

  /// Снимок полей для заполнения формы из сохранённой задачи.
  static TaskCreationInputEntity fromEntity(TaskEntity entity) {
    var startAt = entity.startAt;
    var endAt = entity.endAt;
    if (!entity.isAllDay &&
        startAt == null &&
        endAt == null &&
        entity.dueAt != null) {
      endAt = entity.dueAt;
      final duration = entity.durationMinutes;
      startAt = duration != null && duration > 0
          ? endAt!.subtract(Duration(minutes: duration))
          : endAt;
    }

    final dueDateOnly = entity.isAllDay && entity.dueAt != null
        ? DateTime(
            entity.dueAt!.year,
            entity.dueAt!.month,
            entity.dueAt!.day,
          )
        : null;

    return TaskCreationInputEntity(
      title: entity.title,
      description: entity.description,
      listId: entity.listId,
      parentTaskId: entity.parentTaskId,
      ownerUserId: entity.ownerUserId,
      ownerNameSnapshot: entity.ownerNameSnapshot,
      executorUserId: entity.executorUserId,
      executorTeamId: entity.executorTeamId,
      observerUserId: entity.observerUserId,
      observerTeamId: entity.observerTeamId,
      dueDateOnly: dueDateOnly,
      isAllDay: entity.isAllDay,
      startAt: entity.isAllDay ? null : startAt,
      endAt: entity.isAllDay ? null : endAt,
      reminderPreset: entity.reminderPreset,
      customReminderAt: entity.customReminderAt,
      recurrenceWeekdaysMask: entity.recurrenceWeekdaysMask,
      recurrenceReminderMinutesFromMidnight:
          entity.recurrenceReminderMinutesFromMidnight,
      importance: entity.importance,
      complexity: entity.complexity,
      priority: entity.priority,
      tags: List<String>.of(entity.tags),
      imageAttachments: List<TaskImageAttachmentEntity>.of(
        entity.imageAttachments,
      ),
      estimatedCost: entity.estimatedCost,
      materialRequirements: List<TaskMaterialRequirementEntity>.of(
        entity.materialRequirements,
      ),
      dependencyTaskIds: List<String>.of(entity.dependencyTaskIds),
    );
  }
}
