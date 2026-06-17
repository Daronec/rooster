import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/features/tasks/data/mappers/task_entity_codec.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Чтение задач из Hive без постановки в sync queue (общая логика репозитория и use cases).
final class TasksHiveBoxReader {
  const TasksHiveBoxReader._();

  /// Все задачи из бокса, отсортированные по [TaskEntity.updatedAtMillis] убыванию.
  static List<TaskEntity> readAllSortedByUpdatedDesc(Box<dynamic> box) {
    final out = <TaskEntity>[];
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        out.add(
          TaskEntityCodec.fromMap(Map<String, dynamic>.from(raw)),
        );
      }
    }
    out.sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
    return out;
  }

  /// Индекс id → задача (порядок не гарантирован; для графа зависимостей).
  static Map<String, TaskEntity> readAllAsMapById(Box<dynamic> box) {
    final map = <String, TaskEntity>{};
    for (final key in box.keys) {
      final raw = box.get(key);
      if (raw is Map) {
        final task = TaskEntityCodec.fromMap(Map<String, dynamic>.from(raw));
        map[task.id] = task;
      }
    }
    return map;
  }
}
