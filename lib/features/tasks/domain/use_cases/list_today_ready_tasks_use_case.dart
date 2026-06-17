import 'package:rooster/features/tasks/domain/decision/calculate_task_feasibility.dart';
import 'package:rooster/features/tasks/domain/decision/decision_today_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';

/// Список задач в статусе [TaskFeasibilityStatusEntity.ready] с сортировкой по score (D3-02).
final class ListTodayReadyTasksUseCase {
  /// DI.
  ListTodayReadyTasksUseCase({
    required IBudgetRepository budgetRepository,
    required IMaterialStockRepository materialStockRepository,
    required CalculateTaskFeasibility feasibilityCalculator,
  })  : _budgetRepository = budgetRepository,
        _materialStockRepository = materialStockRepository,
        _feasibilityCalculator = feasibilityCalculator;

  final IBudgetRepository _budgetRepository;
  final IMaterialStockRepository _materialStockRepository;
  final CalculateTaskFeasibility _feasibilityCalculator;

  /// [tasksById] — согласованный снимок; учитываются только [TaskStatusEntity.pending].
  Future<List<TaskFeasibilityListEntryEntity>> execute({
    required Map<String, TaskEntity> tasksById,
    int limit = 3,
  }) async {
    final snapshot = await loadTodaySnapshot(
      tasksById: tasksById,
      visibleLimit: limit,
    );
    return snapshot.visibleEntries;
  }

  /// Полный подсчёт ready и видимая порция (один проход по бюджету/складу).
  Future<DecisionTodaySnapshotEntity> loadTodaySnapshot({
    required Map<String, TaskEntity> tasksById,
    required int visibleLimit,
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
      if (result.status == TaskFeasibilityStatusEntity.ready) {
        entries.add(
          TaskFeasibilityListEntryEntity(task: task, feasibility: result),
        );
      }
    }
    entries.sort(
      (a, b) => b.feasibility.score.compareTo(a.feasibility.score),
    );
    final total = entries.length;
    final safeVisibleLimit = visibleLimit < 1 ? 1 : visibleLimit;
    final visible = total <= safeVisibleLimit
        ? entries
        : entries.sublist(0, safeVisibleLimit);
    return DecisionTodaySnapshotEntity(
      totalReadyCount: total,
      visibleEntries: visible,
    );
  }
}
