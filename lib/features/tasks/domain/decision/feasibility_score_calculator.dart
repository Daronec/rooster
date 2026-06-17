import 'package:rooster/features/tasks/domain/decision/i_feasibility_scoring_policy.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity_monetary_total.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';

/// Чистый расчёт Feasibility Score по политике (SRP: только арифметика, без статусов).
final class FeasibilityScoreCalculator {
  /// [policy] подставляется снаружи (DIP).
  FeasibilityScoreCalculator({required IFeasibilityScoringPolicy policy})
      : _policy = policy;

  final IFeasibilityScoringPolicy _policy;

  /// Итоговый score для отображения и сортировки.
  double computeForTask({
    required TaskEntity task,
    required double budgetRemaining,
    required int unresolvedDependencyCount,
    required int requiredMaterialCount,
    required int satisfiedMaterialCount,
  }) {
    final importance = task.importance.clamp(1, 5);
    final complexity = task.complexity.clamp(1, 5);

    final base = _policy.baseTerm(
      importance,
      _priorityWeight(task.priority),
    );
    final penaltyComplexity = _policy.complexityPenalty(complexity);
    final penaltyCost = _policy.costPenalty(
      TaskEntityMonetaryTotal.budgetedAmount(task),
      budgetRemaining,
    );
    final bonusMaterials = _policy.materialsBonus(
      requiredCount: requiredMaterialCount,
      satisfiedCount: satisfiedMaterialCount,
    );
    final penaltyDeps =
        _policy.dependenciesPenalty(unresolvedDependencyCount);

    final raw = base -
        penaltyComplexity -
        penaltyCost +
        bonusMaterials -
        penaltyDeps;
    return _policy.clampScore(raw);
  }

  static int _priorityWeight(TaskPriorityEntity priority) {
    return switch (priority) {
      TaskPriorityEntity.none => 1,
      TaskPriorityEntity.low => 2,
      TaskPriorityEntity.normal => 3,
      TaskPriorityEntity.high => 4,
      TaskPriorityEntity.urgent => 5,
    };
  }
}
