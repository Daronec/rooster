import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_resolver.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';

void main() {
  group('TaskFeasibilityResolver', () {
    test('completed → done без проверки ресурсов', () {
      final task = _task(
        id: 'a',
        status: TaskStatusEntity.completed,
        deps: const [],
        stockLinkedMaterialIds: const ['m1'],
        cost: 9999,
      );
      final resolution = TaskFeasibilityResolver.resolve(
        task: task,
        tasksById: {'a': task},
        stockItems: const [],
        budget: const BudgetPeriodEntity(
          year: 2026,
          month: 4,
          amountLimit: 0,
        ),
      );
      expect(resolution.status, TaskFeasibilityStatusEntity.done);
    });

    test('незавершённый предшественник → blockedDependencies', () {
      final blocked = _task(
        id: 'a',
        status: TaskStatusEntity.pending,
        deps: const ['b'],
        stockLinkedMaterialIds: const [],
        cost: 0,
      );
      final predecessor = _task(
        id: 'b',
        status: TaskStatusEntity.pending,
        deps: const [],
        stockLinkedMaterialIds: const [],
        cost: 0,
      );
      final resolution = TaskFeasibilityResolver.resolve(
        task: blocked,
        tasksById: {'a': blocked, 'b': predecessor},
        stockItems: const [],
        budget: const BudgetPeriodEntity(
          year: 2026,
          month: 4,
          amountLimit: 10000,
        ),
      );
      expect(resolution.status, TaskFeasibilityStatusEntity.blockedDependencies);
      expect(resolution.detail?.blockingTaskIds, contains('b'));
    });

    test('нехватка денег → blockedMoney', () {
      final task = _task(
        id: 'pay',
        status: TaskStatusEntity.pending,
        deps: const [],
        stockLinkedMaterialIds: const [],
        cost: 500,
      );
      final resolution = TaskFeasibilityResolver.resolve(
        task: task,
        tasksById: {'pay': task},
        stockItems: const [],
        budget: const BudgetPeriodEntity(
          year: 2026,
          month: 4,
          amountLimit: 100,
          amountSpent: 50,
        ),
      );
      expect(resolution.status, TaskFeasibilityStatusEntity.blockedMoney);
      expect(resolution.detail?.moneyDeficit, greaterThan(0));
    });

    test('нехватка материалов → blockedMaterials', () {
      final task = _task(
        id: 'mat',
        status: TaskStatusEntity.pending,
        deps: const [],
        stockLinkedMaterialIds: const ['sand', 'cement'],
        cost: 0,
      );
      final resolution = TaskFeasibilityResolver.resolve(
        task: task,
        tasksById: {'mat': task},
        stockItems: [
          const MaterialStockItemEntity(
            id: 'sand',
            name: 'Песок',
            quantity: 10,
          ),
        ],
        budget: const BudgetPeriodEntity(
          year: 2026,
          month: 4,
          amountLimit: 1000,
        ),
      );
      expect(resolution.status, TaskFeasibilityStatusEntity.blockedMaterials);
      expect(resolution.detail?.missingMaterialIds, contains('cement'));
    });

    test('всё ок → ready', () {
      final task = _task(
        id: 'ok',
        status: TaskStatusEntity.pending,
        deps: const ['done'],
        stockLinkedMaterialIds: const ['x'],
        cost: 10,
      );
      final done = _task(
        id: 'done',
        status: TaskStatusEntity.completed,
        deps: const [],
        stockLinkedMaterialIds: const [],
        cost: 0,
      );
      final resolution = TaskFeasibilityResolver.resolve(
        task: task,
        tasksById: {'ok': task, 'done': done},
        stockItems: [
          const MaterialStockItemEntity(
            id: 'x',
            name: 'X',
            quantity: 1,
          ),
        ],
        budget: const BudgetPeriodEntity(
          year: 2026,
          month: 4,
          amountLimit: 100,
        ),
      );
      expect(resolution.status, TaskFeasibilityStatusEntity.ready);
    });
  });
}

TaskEntity _task({
  required String id,
  required TaskStatusEntity status,
  required List<String> deps,
  required List<String> stockLinkedMaterialIds,
  required double cost,
}) {
  return TaskEntity(
    id: id,
    listId: 'l',
    title: id,
    updatedAtMillis: 0,
    status: status,
    dependencyTaskIds: deps,
    materialRequirements: <TaskMaterialRequirementEntity>[
      for (final stockId in stockLinkedMaterialIds)
        TaskMaterialRequirementEntity(
          id: '${id}_$stockId',
          name: stockId,
          requiredQuantity: 1,
          lineCost: 0,
          stockItemId: stockId,
        ),
    ],
    estimatedCost: cost,
  );
}
