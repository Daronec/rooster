import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';

/// Сериализация [TaskListEntity] ↔ Hive.
final class TaskListEntityCodec {
  const TaskListEntityCodec._();

  /// Карта для Hive.
  static Map<String, Object?> toMap(TaskListEntity entity) {
    return {
      'id': entity.id,
      'name': entity.name,
      'colorArgb': entity.colorArgb,
      'contentRevision': entity.contentRevision,
      'updatedAtMillis': entity.updatedAtMillis,
    };
  }

  /// Восстановление из Hive.
  static TaskListEntity fromMap(Map<String, dynamic> map) {
    return TaskListEntity(
      id: map['id'] as String,
      name: map['name'] as String? ?? '',
      colorArgb: (map['colorArgb'] as num?)?.toInt() ?? 0xFF6200EE,
      contentRevision: (map['contentRevision'] as num?)?.toInt() ?? 0,
      updatedAtMillis: (map['updatedAtMillis'] as num?)?.toInt() ?? 0,
    );
  }
}
