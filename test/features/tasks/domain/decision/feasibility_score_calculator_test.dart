import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/decision/default_feasibility_scoring_policy.dart';
import 'package:rooster/features/tasks/domain/decision/feasibility_score_calculator.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';

void main() {
  const policy = DefaultFeasibilityScoringPolicy();
  final calculator = FeasibilityScoreCalculator(policy: policy);

  group('FeasibilityScoreCalculator', () {
    test('траншея выше септика по score при типичных вводах (план: простая vs дорогая)', () {
      final trench = _task(
        id: 'trench',
        importance: 4,
        priority: TaskPriorityEntity.high,
        complexity: 2,
        estimatedCost: 80,
      );
      final septic = _task(
        id: 'septic',
        importance: 4,
        priority: TaskPriorityEntity.high,
        complexity: 5,
        estimatedCost: 12000,
      );

      final trenchScore = calculator.computeForTask(
        task: trench,
        budgetRemaining: 2000,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );
      final septicScore = calculator.computeForTask(
        task: septic,
        budgetRemaining: 2000,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );

      expect(trenchScore, greaterThan(septicScore));
    });

    test('границы рейтингов 1–5: экстремумы не ломают расчёт', () {
      final low = _task(
        id: 'low',
        importance: 1,
        priority: TaskPriorityEntity.none,
        complexity: 5,
        estimatedCost: 0,
      );
      final high = _task(
        id: 'high',
        importance: 5,
        priority: TaskPriorityEntity.urgent,
        complexity: 1,
        estimatedCost: 0,
      );

      final lowScore = calculator.computeForTask(
        task: low,
        budgetRemaining: 1000,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );
      final highScore = calculator.computeForTask(
        task: high,
        budgetRemaining: 1000,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );

      expect(highScore, greaterThan(lowScore));
    });

    test('нулевой остаток бюджета и ненулевая стоимость сильно снижают score', () {
      final task = _task(
        id: 'costly',
        importance: 3,
        complexity: 2,
        estimatedCost: 500,
      );

      final withBudget = calculator.computeForTask(
        task: task,
        budgetRemaining: 1000,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );
      final noBudget = calculator.computeForTask(
        task: task,
        budgetRemaining: 0,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );

      expect(withBudget, greaterThan(noBudget));
    });

    test('пустые зависимости не добавляют штраф', () {
      final task = _task(
        id: 'solo',
        importance: 3,
        complexity: 3,
        estimatedCost: 0,
      );

      final noDeps = calculator.computeForTask(
        task: task,
        budgetRemaining: 100,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );
      final withDeps = calculator.computeForTask(
        task: task,
        budgetRemaining: 100,
        unresolvedDependencyCount: 3,
        requiredMaterialCount: 0,
        satisfiedMaterialCount: 0,
      );

      expect(noDeps, greaterThan(withDeps));
    });

    test('бонус за полностью укомплектованные материалы', () {
      final task = _task(
        id: 'm',
        importance: 2,
        priority: TaskPriorityEntity.low,
        complexity: 2,
        estimatedCost: 0,
      );

      final withoutBonus = calculator.computeForTask(
        task: task,
        budgetRemaining: 100,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 2,
        satisfiedMaterialCount: 1,
      );
      final withBonus = calculator.computeForTask(
        task: task,
        budgetRemaining: 100,
        unresolvedDependencyCount: 0,
        requiredMaterialCount: 2,
        satisfiedMaterialCount: 2,
      );

      expect(withBonus, greaterThan(withoutBonus));
    });
  });
}

TaskEntity _task({
  required String id,
  required int importance,
  required int complexity,
  required double estimatedCost,
  TaskPriorityEntity priority = TaskPriorityEntity.normal,
}) {
  return TaskEntity(
    id: id,
    listId: 'list',
    title: id,
    updatedAtMillis: 0,
    importance: importance,
    complexity: complexity,
    estimatedCost: estimatedCost,
    priority: priority,
  );
}
