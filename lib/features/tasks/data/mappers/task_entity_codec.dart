import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_image_attachment_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';

/// Сериализация [TaskEntity] ↔ Hive / JSON-подобные карты.
final class TaskEntityCodec {
  const TaskEntityCodec._();

  /// Текущая версия полей задачи в Hive (миграции читают отсутствующие ключи как дефолты).
  static const int currentSchemaVersion = 9;

  /// Карта для Hive.
  static Map<String, Object?> toMap(TaskEntity entity) {
    return {
      'schemaVersion': currentSchemaVersion,
      'id': entity.id,
      'listId': entity.listId,
      if (entity.parentTaskId != null) 'parentTaskId': entity.parentTaskId,
      if (entity.ownerUserId != null) 'ownerUserId': entity.ownerUserId,
      'ownerNameSnapshot': entity.ownerNameSnapshot,
      if (entity.executorUserId != null)
        'executorUserId': entity.executorUserId,
      if (entity.executorTeamId != null)
        'executorTeamId': entity.executorTeamId,
      if (entity.observerUserId != null)
        'observerUserId': entity.observerUserId,
      if (entity.observerTeamId != null)
        'observerTeamId': entity.observerTeamId,
      'isPinned': entity.isPinned,
      'importance': entity.importance,
      'complexity': entity.complexity,
      'estimatedCost': entity.estimatedCost,
      'materialRequirements': entity.materialRequirements
          .map(_materialRequirementToMap)
          .toList(growable: false),
      'dependencyTaskIds': entity.dependencyTaskIds,
      'title': entity.title,
      'description': entity.description,
      'dueAt': entity.dueAt?.toIso8601String(),
      'isAllDay': entity.isAllDay,
      'startAt': entity.startAt?.toIso8601String(),
      'endAt': entity.endAt?.toIso8601String(),
      'durationMinutes': entity.durationMinutes,
      'reminderOffsetMinutes': entity.reminderOffsetMinutes,
      'reminderPreset': entity.reminderPreset.name,
      'customReminderAt': entity.customReminderAt?.toIso8601String(),
      'priority': entity.priority.name,
      'tags': entity.tags,
      'recurrenceWeekdaysMask': entity.recurrenceWeekdaysMask,
      'recurrenceReminderMinutesFromMidnight':
          entity.recurrenceReminderMinutesFromMidnight,
      'imageAttachments': entity.imageAttachments
          .map(_imageAttachmentToMap)
          .toList(growable: false),
      'status': entity.status.name,
      'contentRevision': entity.contentRevision,
      'updatedAtMillis': entity.updatedAtMillis,
      'syncState': entity.syncState.name,
    };
  }

  /// Восстановление из Hive.
  static TaskEntity fromMap(Map<String, dynamic> map) {
    return TaskEntity(
      id: map['id'] as String,
      listId: map['listId'] as String,
      parentTaskId: _readNullableString(map['parentTaskId']),
      ownerUserId: _readNullableString(map['ownerUserId']),
      ownerNameSnapshot: map['ownerNameSnapshot'] as String? ?? '',
      executorUserId: _readNullableString(
        map['executorUserId'] ?? map['participantUserId'],
      ),
      executorTeamId: _readNullableString(
        map['executorTeamId'] ?? map['participantTeamId'],
      ),
      observerUserId: _readNullableString(map['observerUserId']),
      observerTeamId: _readNullableString(map['observerTeamId']),
      isPinned: map['isPinned'] as bool? ?? false,
      importance: _readIntInRange(map['importance'], fallback: 3),
      complexity: _readIntInRange(map['complexity'], fallback: 3),
      estimatedCost: _readDoubleNonNegative(map['estimatedCost']),
      materialRequirements: _readMaterialRequirements(map),
      dependencyTaskIds: _readStringIdList(map['dependencyTaskIds']),
      title: map['title'] as String? ?? '',
      description: map['description'] as String? ?? '',
      dueAt: map['dueAt'] != null
          ? DateTime.tryParse(map['dueAt'] as String)
          : null,
      isAllDay: map['isAllDay'] as bool? ?? false,
      startAt: map['startAt'] != null
          ? DateTime.tryParse(map['startAt'] as String)
          : null,
      endAt: map['endAt'] != null
          ? DateTime.tryParse(map['endAt'] as String)
          : null,
      durationMinutes: (map['durationMinutes'] as num?)?.toInt(),
      reminderOffsetMinutes: (map['reminderOffsetMinutes'] as num?)?.toInt(),
      reminderPreset: _parseReminderPreset(map['reminderPreset'] as String?),
      customReminderAt: map['customReminderAt'] != null
          ? DateTime.tryParse(map['customReminderAt'] as String)
          : null,
      priority: _parsePriority(map['priority'] as String?),
      tags: (map['tags'] as List?)?.cast<String>() ?? const [],
      recurrenceWeekdaysMask:
          (map['recurrenceWeekdaysMask'] as num?)?.toInt() ?? 0,
      recurrenceReminderMinutesFromMidnight:
          (map['recurrenceReminderMinutesFromMidnight'] as num?)?.toInt(),
      imageAttachments: _readImageAttachments(map),
      status: _parseStatus(map['status'] as String?),
      contentRevision: (map['contentRevision'] as num?)?.toInt() ?? 0,
      updatedAtMillis: (map['updatedAtMillis'] as num?)?.toInt() ?? 0,
      syncState: TaskSyncStateEntity.values.byName(
        map['syncState'] as String? ?? TaskSyncStateEntity.pendingSync.name,
      ),
    );
  }

  static Map<String, Object?> _imageAttachmentToMap(
    TaskImageAttachmentEntity entity,
  ) {
    return <String, Object?>{
      'localPath': entity.localPath,
      if (entity.remoteUrl != null) 'remoteUrl': entity.remoteUrl,
    };
  }

  static List<TaskImageAttachmentEntity> _readImageAttachments(
    Map<String, dynamic> map,
  ) {
    final raw = map['imageAttachments'];
    if (raw is List) {
      final out = <TaskImageAttachmentEntity>[];
      for (final entry in raw) {
        if (entry is! Map) {
          continue;
        }
        final local = (entry['localPath'] as String?)?.trim() ?? '';
        if (local.isEmpty) {
          continue;
        }
        out.add(
          TaskImageAttachmentEntity(
            localPath: local,
            remoteUrl: entry['remoteUrl'] as String?,
          ),
        );
      }
      return List<TaskImageAttachmentEntity>.unmodifiable(out);
    }

    final legacyLocal = (map['imageLocalPath'] as String?)?.trim() ?? '';
    final legacyRemote = (map['imageRemoteUrl'] as String?)?.trim();
    if (legacyLocal.isEmpty && (legacyRemote == null || legacyRemote.isEmpty)) {
      return const [];
    }
    final local = legacyLocal;
    return List<TaskImageAttachmentEntity>.unmodifiable(
      [
        TaskImageAttachmentEntity(
          localPath: local,
          remoteUrl: legacyRemote?.isEmpty ?? true ? null : legacyRemote,
        ),
      ],
    );
  }

  static TaskStatusEntity _parseStatus(String? raw) {
    if (raw == null || raw.isEmpty) {
      return TaskStatusEntity.pending;
    }
    for (final status in TaskStatusEntity.values) {
      if (status.name == raw) {
        return status;
      }
    }
    return TaskStatusEntity.pending;
  }

  /// Читает целое 1–5 для рейтингов задачи; при отсутствии или мусоре — [fallback].
  static int _readIntInRange(Object? raw, {required int fallback}) {
    final parsed = (raw as num?)?.toInt();
    if (parsed == null) {
      return fallback;
    }
    return parsed.clamp(1, 5);
  }

  /// Неотрицательная стоимость; для старых записей без ключа — 0.
  static double _readDoubleNonNegative(Object? raw) {
    final parsed = (raw as num?)?.toDouble();
    if (parsed == null || parsed.isNaN) {
      return 0;
    }
    return parsed < 0 ? 0 : parsed;
  }

  static Map<String, Object?> _materialRequirementToMap(
    TaskMaterialRequirementEntity entity,
  ) {
    return <String, Object?>{
      'id': entity.id,
      'name': entity.name,
      'requiredQuantity': entity.requiredQuantity,
      'lineCost': entity.lineCost,
      if (entity.stockItemId != null) 'stockItemId': entity.stockItemId,
    };
  }

  /// Читает [materialRequirements] или мигрирует из [materialRequirementIds] (схема 1).
  static List<TaskMaterialRequirementEntity> _readMaterialRequirements(
    Map<String, dynamic> map,
  ) {
    if (map.containsKey('materialRequirements')) {
      final raw = map['materialRequirements'];
      if (raw is! List) {
        return const [];
      }
      final out = <TaskMaterialRequirementEntity>[];
      for (final entry in raw) {
        if (entry is! Map) {
          continue;
        }
        final id = entry['id'] as String? ?? '';
        if (id.isEmpty) {
          continue;
        }
        out.add(
          TaskMaterialRequirementEntity(
            id: id,
            name: entry['name'] as String? ?? '',
            requiredQuantity: _readDoubleNonNegative(entry['requiredQuantity']),
            lineCost: _readDoubleNonNegative(entry['lineCost']),
            stockItemId: entry['stockItemId'] as String?,
          ),
        );
      }
      return List<TaskMaterialRequirementEntity>.unmodifiable(out);
    }
    return _materialRequirementsFromLegacyIds(map['materialRequirementIds']);
  }

  static List<TaskMaterialRequirementEntity> _materialRequirementsFromLegacyIds(
    Object? raw,
  ) {
    final ids = _readStringIdList(raw);
    if (ids.isEmpty) {
      return const [];
    }
    return List<TaskMaterialRequirementEntity>.unmodifiable(
      ids
          .map(
            (id) => TaskMaterialRequirementEntity(
              id: id,
              name: id,
              requiredQuantity: 1,
              lineCost: 0,
              stockItemId: id,
            ),
          )
          .toList(growable: false),
    );
  }

  /// Список id из Hive (List или null).
  static List<String> _readStringIdList(Object? raw) {
    if (raw is! List) {
      return const [];
    }
    return raw
        .map((e) => '$e')
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static String? _readNullableString(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static TaskPriorityEntity _parsePriority(String? raw) {
    if (raw == null || raw.isEmpty) {
      return TaskPriorityEntity.normal;
    }
    for (final value in TaskPriorityEntity.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return TaskPriorityEntity.normal;
  }

  static TaskReminderPresetEntity _parseReminderPreset(String? raw) {
    if (raw == null || raw.isEmpty) {
      return TaskReminderPresetEntity.none;
    }
    for (final value in TaskReminderPresetEntity.values) {
      if (value.name == raw) {
        return value;
      }
    }
    return TaskReminderPresetEntity.none;
  }
}
