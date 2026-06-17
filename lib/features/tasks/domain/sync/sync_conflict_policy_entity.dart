import 'package:rooster/features/tasks/domain/entities/task_entity.dart' show TaskEntity;

/// Политики разрешения конфликтов локаль ↔ облако.
enum SyncConflictPolicyEntity {
  /// Последняя запись по [TaskEntity.updatedAtMillis] побеждает.
  lastWriteWins,

  /// Сравнение [TaskEntity.contentRevision] и серверного `version`.
  versionVector,

  /// Серверное слияние через Cloud Function (источник истины — ответ функции).
  serverMerge,
}
