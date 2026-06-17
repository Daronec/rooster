import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';

/// Кодек записи истории изменений задачи для хранения в Hive (Map).
final class TaskChangeEntityCodec {
  TaskChangeEntityCodec._();

  /// Преобразует доменную запись истории в карту для Hive.
  static Map<String, dynamic> toMap(TaskChangeEntity entity) {
    return <String, dynamic>{
      'id': entity.id,
      'taskId': entity.taskId,
      'kind': entity.kind.name,
      'changedAtMillis': entity.changedAtMillis,
      'changedFields': entity.changedFields.map((field) => field.name).toList(),
      'taskTitleSnapshot': entity.taskTitleSnapshot,
      'authorNameSnapshot': entity.authorNameSnapshot,
    };
  }

  /// Восстанавливает доменную запись истории из карты Hive.
  static TaskChangeEntity fromMap(Map<String, dynamic> map) {
    final kindRaw =
        (map['kind'] as String?) ?? TaskChangeKindEntity.updated.name;
    final kind = TaskChangeKindEntity.values.firstWhere(
      (value) => value.name == kindRaw,
      orElse: () => TaskChangeKindEntity.updated,
    );
    final fieldsRaw = (map['changedFields'] as List?) ?? const [];
    final changedFields = fieldsRaw
        .whereType<String>()
        .map(
          (name) => TaskChangeFieldEntity.values.firstWhere(
            (value) => value.name == name,
            orElse: () => TaskChangeFieldEntity.description,
          ),
        )
        .toList(growable: false);
    return TaskChangeEntity(
      id: (map['id'] as String?) ?? '',
      taskId: (map['taskId'] as String?) ?? '',
      kind: kind,
      changedAtMillis: (map['changedAtMillis'] as int?) ?? 0,
      changedFields: changedFields,
      taskTitleSnapshot: (map['taskTitleSnapshot'] as String?) ?? '',
      authorNameSnapshot: (map['authorNameSnapshot'] as String?) ?? '',
    );
  }
}
