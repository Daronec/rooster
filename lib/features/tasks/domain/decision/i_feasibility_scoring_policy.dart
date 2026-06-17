/// Политика весов и штрафов для [FeasibilityScoreCalculator] (OCP: новая политика — новый класс).
abstract interface class IFeasibilityScoringPolicy {
  /// Базовая часть: важность и срочность (после нормализации 1–5).
  double baseTerm(int importance, int priorityWeight);

  /// Штраф за сложность.
  double complexityPenalty(int complexity);

  /// Штраф за давление на бюджет (f из спецификации).
  double costPenalty(double estimatedCost, double budgetRemaining);

  /// Бонус за удовлетворённые требования к материалам (g).
  double materialsBonus({
    required int requiredCount,
    required int satisfiedCount,
  });

  /// Штраф за незакрытые зависимости (h).
  double dependenciesPenalty(int unresolvedDependencyCount);

  /// Ограничение итогового score для стабильной сортировки в UI.
  double clampScore(double raw);
}
