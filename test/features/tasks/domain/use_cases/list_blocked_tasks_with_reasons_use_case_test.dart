import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/decision/calculate_task_feasibility.dart';
import 'package:rooster/features/tasks/domain/decision/default_feasibility_scoring_policy.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_blocked_tasks_with_reasons_use_case.dart';

void main() {
  test('архив и completed не входят в список заблокированных', () async {
    final budget = _StubBudget();
    final stock = _StubStock();
    final useCase = ListBlockedTasksWithReasonsUseCase(
      budgetRepository: budget,
      materialStockRepository: stock,
      feasibilityCalculator: CalculateTaskFeasibility(
        policy: const DefaultFeasibilityScoringPolicy(),
      ),
    );

    final tasksById = <String, TaskEntity>{
      'arch': const TaskEntity(
        id: 'arch',
        listId: 'l',
        title: 'Arch',
        updatedAtMillis: 1,
        status: TaskStatusEntity.archived,
      ),
      'done': const TaskEntity(
        id: 'done',
        listId: 'l',
        title: 'Done',
        updatedAtMillis: 2,
        status: TaskStatusEntity.completed,
      ),
      'blocked': const TaskEntity(
        id: 'blocked',
        listId: 'l',
        title: 'Blocked',
        updatedAtMillis: 3,
        estimatedCost: 99999,
      ),
    };

    final blocked = await useCase.execute(tasksById: tasksById);
    expect(blocked.length, 1);
    expect(blocked.single.task.id, 'blocked');
    expect(
      blocked.single.feasibility.status,
      TaskFeasibilityStatusEntity.blockedMoney,
    );
  });
}

final class _StubBudget implements IBudgetRepository {
  @override
  Future<BudgetPeriodEntity?> readActivePeriod() async =>
      const BudgetPeriodEntity(year: 2026, month: 1, amountLimit: 10);

  @override
  Stream<BudgetPeriodEntity?> watchActivePeriod() =>
      Stream<BudgetPeriodEntity?>.value(
        const BudgetPeriodEntity(year: 2026, month: 1, amountLimit: 10),
      );

  @override
  Future<void> saveActivePeriod(BudgetPeriodEntity period) async {}

  @override
  Future<void> clearActivePeriod() async {}
}

final class _StubStock implements IMaterialStockRepository {
  @override
  Future<List<MaterialStockItemEntity>> readAllItems() async => const [];

  @override
  Future<void> saveAllItems(List<MaterialStockItemEntity> items) async {}

  @override
  Future<void> mergeRemoteStockIfNewer(
    MaterialStockSnapshotEntity remote,
  ) async {}
}
