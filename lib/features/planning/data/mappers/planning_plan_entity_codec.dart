import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/entities/planning_task_entity.dart';

/// Кодек планов для локального Hive-хранилища.
abstract final class PlanningPlanEntityCodec {
  /// Преобразовать [entity] в Map.
  static Map<String, Object?> toMap(PlanningPlanEntity entity) {
    return <String, Object?>{
      'id': entity.id,
      'title': entity.title,
      'goalDescription': entity.goalDescription,
      'periodStartMillis': entity.periodStartMillis,
      'periodEndMillis': entity.periodEndMillis,
      'tasks': entity.tasks.map(_taskToMap).toList(growable: false),
      'createdAtMillis': entity.createdAtMillis,
      'updatedAtMillis': entity.updatedAtMillis,
      'contentRevision': entity.contentRevision,
    };
  }

  /// Прочитать план из [map].
  static PlanningPlanEntity fromMap(Map<String, dynamic> map) {
    return PlanningPlanEntity(
      id: map['id'] as String? ?? '',
      title: map['title'] as String? ?? '',
      goalDescription: map['goalDescription'] as String? ?? '',
      periodStartMillis: (map['periodStartMillis'] as num?)?.toInt() ?? 0,
      periodEndMillis: (map['periodEndMillis'] as num?)?.toInt() ?? 0,
      tasks: _readTasks(map['tasks']),
      createdAtMillis: (map['createdAtMillis'] as num?)?.toInt() ?? 0,
      updatedAtMillis: (map['updatedAtMillis'] as num?)?.toInt() ?? 0,
      contentRevision: (map['contentRevision'] as num?)?.toInt() ?? 0,
    );
  }

  static Map<String, Object?> _taskToMap(PlanningTaskEntity entity) {
    return <String, Object?>{
      'id': entity.id,
      'title': entity.title,
      'order': entity.order,
      'importance': entity.importance,
      'isCompleted': entity.isCompleted,
      'createdAtMillis': entity.createdAtMillis,
      'updatedAtMillis': entity.updatedAtMillis,
    };
  }

  static List<PlanningTaskEntity> _readTasks(Object? raw) {
    if (raw is! List) {
      return const <PlanningTaskEntity>[];
    }
    final tasks = <PlanningTaskEntity>[];
    for (final item in raw) {
      if (item is! Map) {
        continue;
      }
      final map = Map<String, dynamic>.from(item);
      tasks.add(
        PlanningTaskEntity(
          id: map['id'] as String? ?? '',
          title: map['title'] as String? ?? '',
          order: (map['order'] as num?)?.toInt() ?? tasks.length,
          importance: (map['importance'] as num?)?.toInt() ?? 3,
          isCompleted: map['isCompleted'] as bool? ?? false,
          createdAtMillis: (map['createdAtMillis'] as num?)?.toInt() ?? 0,
          updatedAtMillis: (map['updatedAtMillis'] as num?)?.toInt() ?? 0,
        ),
      );
    }
    tasks.sort((left, right) => left.order.compareTo(right.order));
    return List<PlanningTaskEntity>.unmodifiable(tasks);
  }
}
