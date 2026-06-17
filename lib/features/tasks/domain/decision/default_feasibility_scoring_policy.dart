import 'package:rooster/features/tasks/domain/decision/i_feasibility_scoring_policy.dart';

/// Версия 1 формулы из [DECISION_SYSTEM_IMPLEMENTATION.md]: именованные коэффициенты без магии в теле use case.
final class DefaultFeasibilityScoringPolicy implements IFeasibilityScoringPolicy {
  /// Создаёт политику с коэффициентами по умолчанию.
  const DefaultFeasibilityScoringPolicy();

  /// Вес важности (аналог «×2» в плане).
  static const double weightImportance = 2;

  /// Вес срочности.
  static const double weightUrgency = 2;

  /// Вес штрафа за сложность.
  static const double weightComplexity = 1;

  /// Множитель нехватки средств относительно остатка бюджета.
  static const double weightBudgetShortage = 0.1;

  /// Бонус, если все требуемые материалы на складе в достаточном количестве.
  static const double allMaterialsSatisfiedBonus = 5;

  /// Штраф за каждую незакрытую зависимость.
  static const double weightPerUnresolvedDependency = 3;

  /// Нижняя граница итогового score.
  static const double scoreMin = -100;

  /// Верхняя граница итогового score.
  static const double scoreMax = 200;

  @override
  double baseTerm(int importance, int priorityWeight) {
    final i = importance.clamp(1, 5);
    final p = priorityWeight.clamp(1, 5);
    return i * weightImportance + p * weightUrgency;
  }

  @override
  double complexityPenalty(int complexity) {
    final c = complexity.clamp(1, 5);
    return c * weightComplexity;
  }

  @override
  double costPenalty(double estimatedCost, double budgetRemaining) {
    if (estimatedCost <= 0) {
      return 0;
    }
    final remaining = budgetRemaining < 0 ? 0.0 : budgetRemaining;
    if (remaining >= estimatedCost) {
      return 0;
    }
    final shortage = estimatedCost - remaining;
    return weightBudgetShortage * shortage;
  }

  @override
  double materialsBonus({
    required int requiredCount,
    required int satisfiedCount,
  }) {
    if (requiredCount <= 0) {
      return 0;
    }
    if (satisfiedCount >= requiredCount) {
      return allMaterialsSatisfiedBonus;
    }
    return 0;
  }

  @override
  double dependenciesPenalty(int unresolvedDependencyCount) {
    if (unresolvedDependencyCount <= 0) {
      return 0;
    }
    return unresolvedDependencyCount * weightPerUnresolvedDependency;
  }

  @override
  double clampScore(double raw) {
    if (raw.isNaN) {
      return scoreMin;
    }
    return raw.clamp(scoreMin, scoreMax);
  }
}
