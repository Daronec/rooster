import 'package:rooster/features/planning/domain/entities/planning_task_entity.dart';

/// План работ на период.
final class PlanningPlanEntity {
  /// Создаёт план.
  const PlanningPlanEntity({
    required this.id,
    required this.title,
    required this.goalDescription,
    required this.periodStartMillis,
    required this.periodEndMillis,
    required this.tasks,
    required this.createdAtMillis,
    required this.updatedAtMillis,
    this.contentRevision = 0,
  });

  /// Идентификатор плана.
  final String id;

  /// Название плана.
  final String title;

  /// Описание цели плана.
  final String goalDescription;

  /// Начало периода выполнения.
  final int periodStartMillis;

  /// Конец периода выполнения.
  final int periodEndMillis;

  /// Задачи плана.
  final List<PlanningTaskEntity> tasks;

  /// Время создания.
  final int createdAtMillis;

  /// Время последнего изменения.
  final int updatedAtMillis;

  /// Ревизия содержимого для разрешения конфликтов синхронизации.
  final int contentRevision;

  /// Всего задач в плане.
  int get totalTasks => tasks.length;

  /// Количество выполненных задач.
  int get completedTasks => tasks.where((task) => task.isCompleted).length;

  /// Количество оставшихся задач.
  int get remainingTasks => totalTasks - completedTasks;

  /// Задачи в порядке выполнения.
  List<PlanningTaskEntity> get orderedTasks {
    final ordered = List<PlanningTaskEntity>.of(tasks)
      ..sort((left, right) => left.order.compareTo(right.order));
    return List<PlanningTaskEntity>.unmodifiable(ordered);
  }

  /// Копия с заменой полей.
  PlanningPlanEntity copyWith({
    String? id,
    String? title,
    String? goalDescription,
    int? periodStartMillis,
    int? periodEndMillis,
    List<PlanningTaskEntity>? tasks,
    int? createdAtMillis,
    int? updatedAtMillis,
    int? contentRevision,
  }) {
    return PlanningPlanEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      goalDescription: goalDescription ?? this.goalDescription,
      periodStartMillis: periodStartMillis ?? this.periodStartMillis,
      periodEndMillis: periodEndMillis ?? this.periodEndMillis,
      tasks: List<PlanningTaskEntity>.unmodifiable(tasks ?? this.tasks),
      createdAtMillis: createdAtMillis ?? this.createdAtMillis,
      updatedAtMillis: updatedAtMillis ?? this.updatedAtMillis,
      contentRevision: contentRevision ?? this.contentRevision,
    );
  }
}
