import 'package:rooster/features/tasks/domain/decision/calculate_task_feasibility.dart';
import 'package:rooster/features/tasks/domain/decision/decision_blocked_section_entity.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';

/// Задачи не [TaskFeasibilityStatusEntity.ready] и не [TaskFeasibilityStatusEntity.done] (D3-03).
///
/// Берутся только [TaskStatusEntity.pending] (архив и выполненные не показываем).
final class ListBlockedTasksWithReasonsUseCase {
  /// DI.
  ListBlockedTasksWithReasonsUseCase({
    required IBudgetRepository budgetRepository,
    required IMaterialStockRepository materialStockRepository,
    required CalculateTaskFeasibility feasibilityCalculator,
  })  : _budgetRepository = budgetRepository,
        _materialStockRepository = materialStockRepository,
        _feasibilityCalculator = feasibilityCalculator;

  final IBudgetRepository _budgetRepository;
  final IMaterialStockRepository _materialStockRepository;
  final CalculateTaskFeasibility _feasibilityCalculator;

  /// Сортировка: по убыванию score (важная «почти готовая» выше).
  Future<List<TaskFeasibilityListEntryEntity>> execute({
    required Map<String, TaskEntity> tasksById,
  }) async {
    final budget = await _budgetRepository.readActivePeriod();
    final stockItems = await _materialStockRepository.readAllItems();
    final entries = <TaskFeasibilityListEntryEntity>[];
    for (final task in tasksById.values) {
      if (task.status != TaskStatusEntity.pending) {
        continue;
      }
      final result = _feasibilityCalculator.execute(
        task: task,
        tasksById: tasksById,
        stockItems: stockItems,
        budget: budget,
      );
      if (result.status != TaskFeasibilityStatusEntity.ready &&
          result.status != TaskFeasibilityStatusEntity.done) {
        entries.add(
          TaskFeasibilityListEntryEntity(task: task, feasibility: result),
        );
      }
    }
    entries.sort(
      (a, b) => b.feasibility.score.compareTo(a.feasibility.score),
    );
    return entries;
  }

  /// Группировка по типу блокировки (порядок: зависимости → деньги → материалы).
  Future<List<DecisionBlockedSectionEntity>> loadGroupedSections({
    required Map<String, TaskEntity> tasksById,
  }) async {
    final flat = await execute(tasksById: tasksById);
    final byStatus = <TaskFeasibilityStatusEntity,
        List<TaskFeasibilityListEntryEntity>>{};
    for (final entry in flat) {
      byStatus
          .putIfAbsent(
            entry.feasibility.status,
            () => <TaskFeasibilityListEntryEntity>[],
          )
          .add(entry);
    }
    const order = <TaskFeasibilityStatusEntity>[
      TaskFeasibilityStatusEntity.blockedDependencies,
      TaskFeasibilityStatusEntity.blockedMoney,
      TaskFeasibilityStatusEntity.blockedMaterials,
    ];
    final sections = <DecisionBlockedSectionEntity>[];
    for (final status in order) {
      final bucket = byStatus[status];
      if (bucket != null && bucket.isNotEmpty) {
        sections.add(DecisionBlockedSectionEntity(status: status, entries: bucket));
      }
    }
    return sections;
  }
}
