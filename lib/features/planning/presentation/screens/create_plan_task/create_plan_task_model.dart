import 'package:elementary/elementary.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// Модель экрана создания задачи плана.
final class CreatePlanTaskModel extends ElementaryModel {
  /// Создаёт модель.
  CreatePlanTaskModel({
    required IPlanningRepository planningRepository,
    required ITasksRepository tasksRepository,
    required this.planId,
  }) : _planningRepository = planningRepository,
       _tasksRepository = tasksRepository;

  final IPlanningRepository _planningRepository;
  final ITasksRepository _tasksRepository;

  /// ID плана, к которому добавляется задача.
  final String planId;

  /// Загрузить план по ID.
  Future<PlanningPlanEntity?> loadPlan() =>
      _planningRepository.loadPlan(planId);

  /// Сохранить план.
  Future<void> savePlan(PlanningPlanEntity plan) =>
      _planningRepository.savePlan(plan);

  /// Сохранить задачу в общем хранилище задач.
  Future<void> saveTask(TaskEntity task) => _tasksRepository.saveTask(task);
}
