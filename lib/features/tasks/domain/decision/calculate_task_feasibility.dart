import 'package:rooster/features/tasks/domain/decision/feasibility_score_calculator.dart';
import 'package:rooster/features/tasks/domain/decision/i_feasibility_scoring_policy.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_resolver.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_result_entity.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';

/// Оркестратор: статус по правилам приоритета + score по политике.
final class CalculateTaskFeasibility {
  /// [policy] используется внутренним калькулятором score.
  CalculateTaskFeasibility({required IFeasibilityScoringPolicy policy})
      : _scoreCalculator = FeasibilityScoreCalculator(policy: policy);

  final FeasibilityScoreCalculator _scoreCalculator;

  /// Полный расчёт для одной задачи и снимка контекста (без обращения к репозиториям).
  TaskFeasibilityResultEntity execute({
    required TaskEntity task,
    required Map<String, TaskEntity> tasksById,
    required List<MaterialStockItemEntity> stockItems,
    BudgetPeriodEntity? budget,
  }) {
    final resolution = TaskFeasibilityResolver.resolve(
      task: task,
      tasksById: tasksById,
      stockItems: stockItems,
      budget: budget,
    );

    /// Без активного периода денежный штраф в score не применяется (большой «остаток»).
    final budgetRemainingForScore = budget?.remaining ?? 1e12;
    final unresolved = _unresolvedDependencyCount(task, tasksById);
    final requiredMaterials = _warehouseLinkedRequirementCount(task);
    final satisfiedMaterials = _satisfiedWarehouseLinkedCount(
      task.materialRequirements,
      stockItems,
    );

    final score = _scoreCalculator.computeForTask(
      task: task,
      budgetRemaining: budgetRemainingForScore,
      unresolvedDependencyCount: unresolved,
      requiredMaterialCount: requiredMaterials,
      satisfiedMaterialCount: satisfiedMaterials,
    );

    return TaskFeasibilityResultEntity(
      score: score,
      status: resolution.status,
      detail: resolution.detail,
    );
  }

  static int _unresolvedDependencyCount(
    TaskEntity task,
    Map<String, TaskEntity> tasksById,
  ) {
    var count = 0;
    for (final dependencyId in task.dependencyTaskIds) {
      final predecessor = tasksById[dependencyId];
      final isDone = predecessor?.status == TaskStatusEntity.completed;
      if (!isDone) {
        count++;
      }
    }
    return count;
  }

  static int _warehouseLinkedRequirementCount(TaskEntity task) {
    var count = 0;
    for (final row in task.materialRequirements) {
      final stockId = row.stockItemId;
      if (stockId != null && stockId.isNotEmpty) {
        count++;
      }
    }
    return count;
  }

  static int _satisfiedWarehouseLinkedCount(
    List<TaskMaterialRequirementEntity> requirements,
    List<MaterialStockItemEntity> stockItems,
  ) {
    final byId = <String, double>{
      for (final item in stockItems) item.id: item.quantity,
    };
    final byNormalizedNameToId = <String, String>{
      for (final item in stockItems)
        item.name.trim().toLowerCase(): item.id,
    };
    var satisfied = 0;
    for (final row in requirements) {
      final resolvedStockId =
          (row.stockItemId != null && row.stockItemId!.trim().isNotEmpty)
              ? row.stockItemId!.trim()
              : byNormalizedNameToId[row.name.trim().toLowerCase()];
      if (resolvedStockId == null || resolvedStockId.isEmpty) {
        continue;
      }
      final quantity = byId[resolvedStockId];
      if (quantity != null && quantity >= row.requiredQuantity) {
        satisfied++;
      }
    }
    return satisfied;
  }
}
