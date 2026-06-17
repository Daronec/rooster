import 'package:rooster/features/tasks/domain/entities/task_creation_input_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/services/task_reminder_offset_calculator.dart';

/// Сборка [TaskEntity] из [TaskCreationInputEntity].
final class TaskEntityFromCreationInput {
  const TaskEntityFromCreationInput._();

  /// Строит новую задачу с заданным [id] и [updatedAtMillis].
  static TaskEntity build({
    required TaskCreationInputEntity input,
    required String id,
    required int updatedAtMillis,
  }) {
    final dueAt = _resolveDueAt(input);
    final durationMinutes = _resolveDurationMinutes(input);
    final reminderOffset = TaskReminderOffsetCalculator.minutesBeforeDue(
      preset: input.reminderPreset,
      dueAt: dueAt,
      customReminderAt: input.customReminderAt,
    );

    final mask = input.recurrenceWeekdaysMask;
    final recurrenceMinutes = mask == 0
        ? null
        : input.recurrenceReminderMinutesFromMidnight;

    return _taskFromResolvedFields(
      id: id,
      input: input,
      dueAt: dueAt,
      durationMinutes: durationMinutes,
      reminderOffset: reminderOffset,
      recurrenceMinutes: recurrenceMinutes,
      mask: mask,
      updatedAtMillis: updatedAtMillis,
    );
  }

  /// Обновляет существующую задачу данными формы, сохраняя id, статус и ревизию контента.
  static TaskEntity mergeExisting({
    required TaskEntity existing,
    required TaskCreationInputEntity input,
    required int updatedAtMillis,
  }) {
    final dueAt = _resolveDueAt(input);
    final durationMinutes = _resolveDurationMinutes(input);
    final reminderOffset = TaskReminderOffsetCalculator.minutesBeforeDue(
      preset: input.reminderPreset,
      dueAt: dueAt,
      customReminderAt: input.customReminderAt,
    );
    final mask = input.recurrenceWeekdaysMask;
    final recurrenceMinutes = mask == 0
        ? null
        : input.recurrenceReminderMinutesFromMidnight;

    final draft = _taskFromResolvedFields(
      id: existing.id,
      input: input,
      dueAt: dueAt,
      durationMinutes: durationMinutes,
      reminderOffset: reminderOffset,
      recurrenceMinutes: recurrenceMinutes,
      mask: mask,
      updatedAtMillis: updatedAtMillis,
    );

    final mergedAttachments = _mergeImageAttachments(
      existing: existing.imageAttachments,
      incoming: draft.imageAttachments,
    );

    return TaskEntity(
      id: existing.id,
      listId: draft.listId,
      parentTaskId: draft.parentTaskId,
      ownerUserId: existing.ownerUserId ?? draft.ownerUserId,
      ownerNameSnapshot: existing.ownerNameSnapshot.isNotEmpty
          ? existing.ownerNameSnapshot
          : draft.ownerNameSnapshot,
      executorUserId: draft.executorUserId,
      executorTeamId: draft.executorTeamId,
      observerUserId: draft.observerUserId,
      observerTeamId: draft.observerTeamId,
      importance: draft.importance,
      complexity: draft.complexity,
      estimatedCost: draft.estimatedCost,
      materialRequirements: draft.materialRequirements,
      dependencyTaskIds: draft.dependencyTaskIds,
      title: draft.title,
      description: draft.description,
      dueAt: draft.dueAt,
      isAllDay: draft.isAllDay,
      startAt: draft.startAt,
      endAt: draft.endAt,
      durationMinutes: draft.durationMinutes,
      reminderOffsetMinutes: draft.reminderOffsetMinutes,
      reminderPreset: draft.reminderPreset,
      customReminderAt: draft.customReminderAt,
      priority: draft.priority,
      tags: draft.tags,
      recurrenceWeekdaysMask: draft.recurrenceWeekdaysMask,
      recurrenceReminderMinutesFromMidnight:
          draft.recurrenceReminderMinutesFromMidnight,
      imageAttachments: mergedAttachments,
      status: existing.status,
      contentRevision: existing.contentRevision + 1,
      updatedAtMillis: draft.updatedAtMillis,
      syncState: existing.syncState,
    );
  }

  static List<TaskImageAttachmentEntity> _mergeImageAttachments({
    required List<TaskImageAttachmentEntity> existing,
    required List<TaskImageAttachmentEntity> incoming,
  }) {
    if (incoming.isEmpty) {
      return const [];
    }
    final byLocal = <String, TaskImageAttachmentEntity>{};
    for (final item in existing) {
      if (item.localPath.isEmpty) {
        continue;
      }
      byLocal[item.localPath] = item;
    }
    final out = <TaskImageAttachmentEntity>[];
    for (final item in incoming) {
      if (item.localPath.isEmpty) {
        continue;
      }
      final old = byLocal[item.localPath];
      out.add(
        old == null ? item : old.copyWith(localPath: item.localPath),
      );
    }
    return List<TaskImageAttachmentEntity>.unmodifiable(out);
  }

  static TaskEntity _taskFromResolvedFields({
    required String id,
    required TaskCreationInputEntity input,
    required DateTime? dueAt,
    required int? durationMinutes,
    required int? reminderOffset,
    required int? recurrenceMinutes,
    required int mask,
    required int updatedAtMillis,
  }) {
    final cost = input.estimatedCost < 0 ? 0.0 : input.estimatedCost;
    final materials = List<TaskMaterialRequirementEntity>.unmodifiable(
      List<TaskMaterialRequirementEntity>.of(input.materialRequirements),
    );
    final dependencyTaskIds = _normalizeDependencyTaskIds(
      input.dependencyTaskIds,
    );

    return TaskEntity(
      id: id,
      listId: input.listId,
      parentTaskId: input.parentTaskId,
      ownerUserId: input.ownerUserId,
      ownerNameSnapshot: input.ownerNameSnapshot.trim(),
      executorUserId: input.executorUserId,
      executorTeamId: input.executorTeamId,
      observerUserId: input.observerUserId,
      observerTeamId: input.observerTeamId,
      title: input.title.trim(),
      importance: input.importance.clamp(1, 5),
      complexity: input.complexity.clamp(1, 5),
      description: input.description.trim(),
      dueAt: dueAt,
      isAllDay: input.isAllDay,
      startAt: input.isAllDay ? null : input.startAt,
      endAt: input.isAllDay ? null : input.endAt,
      durationMinutes: durationMinutes,
      reminderOffsetMinutes: reminderOffset,
      reminderPreset: input.reminderPreset,
      customReminderAt: input.reminderPreset == TaskReminderPresetEntity.custom
          ? input.customReminderAt
          : null,
      priority: input.priority,
      tags: List<String>.unmodifiable(input.tags),
      recurrenceWeekdaysMask: mask,
      recurrenceReminderMinutesFromMidnight: recurrenceMinutes,
      imageAttachments: List<TaskImageAttachmentEntity>.unmodifiable(
        input.imageAttachments
            .where((item) => item.localPath.trim().isNotEmpty)
            .map(
              (item) => TaskImageAttachmentEntity(
                localPath: item.localPath.trim(),
                remoteUrl: item.remoteUrl,
              ),
            )
            .toList(growable: false),
      ),
      estimatedCost: cost,
      materialRequirements: materials,
      dependencyTaskIds: dependencyTaskIds,
      updatedAtMillis: updatedAtMillis,
    );
  }

  static List<String> _normalizeDependencyTaskIds(Iterable<String> ids) {
    final seen = <String>{};
    final normalized = <String>[];
    for (final rawId in ids) {
      final id = rawId.trim();
      if (id.isEmpty || seen.contains(id)) {
        continue;
      }
      seen.add(id);
      normalized.add(id);
    }
    return List<String>.unmodifiable(normalized);
  }

  static DateTime? _resolveDueAt(TaskCreationInputEntity input) {
    if (input.isAllDay) {
      return input.dueDateOnly;
    }
    if (input.endAt != null) {
      return input.endAt;
    }
    return input.startAt ?? input.dueDateOnly;
  }

  static int? _resolveDurationMinutes(TaskCreationInputEntity input) {
    if (input.isAllDay) {
      return null;
    }
    final start = input.startAt;
    final end = input.endAt;
    if (start == null || end == null) {
      return null;
    }
    final minutes = end.difference(start).inMinutes;
    return minutes < 0 ? 0 : minutes;
  }
}
