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
import 'package:rooster/features/tasks/domain/use_cases/list_today_ready_tasks_use_case.dart';

/// D3-06: две задачи, зависимость; после completed предшественника — successor в «Сегодня».
void main() {
  test(
    'после completed предшественника зависимая задача попадает в ready-топ',
    () async {
      final budget = _FixedBudget(
        const BudgetPeriodEntity(
          year: 2026,
          month: 6,
          amountLimit: 1000,
        ),
      );
      final stock = _FixedStock(const []);
      final useCase = ListTodayReadyTasksUseCase(
        budgetRepository: budget,
        materialStockRepository: stock,
        feasibilityCalculator: CalculateTaskFeasibility(
          policy: const DefaultFeasibilityScoringPolicy(),
        ),
      );

      const predecessorPending = TaskEntity(
        id: 'pred',
        listId: 'l',
        title: 'Сначала',
        updatedAtMillis: 1,
      );
      const successor = TaskEntity(
        id: 'succ',
        listId: 'l',
        title: 'Потом',
        updatedAtMillis: 2,
        dependencyTaskIds: ['pred'],
      );

      final blockedMap = <String, TaskEntity>{
        'pred': predecessorPending,
        'succ': successor,
      };
      final whileBlocked = await useCase.execute(tasksById: blockedMap);
      expect(
        whileBlocked.map((entry) => entry.task.id).toList(),
        isNot(contains('succ')),
      );

      final predecessorDone = predecessorPending.copyWith(
        status: TaskStatusEntity.completed,
      );
      final unblockedMap = <String, TaskEntity>{
        'pred': predecessorDone,
        'succ': successor,
      };
      final afterComplete = await useCase.execute(tasksById: unblockedMap);
      expect(
        afterComplete.map((entry) => entry.task.id),
        contains('succ'),
      );
      final successorEntry = afterComplete.firstWhere(
        (entry) => entry.task.id == 'succ',
      );
      expect(
        successorEntry.feasibility.status,
        TaskFeasibilityStatusEntity.ready,
      );
    },
  );
}

final class _FixedBudget implements IBudgetRepository {
  _FixedBudget(this._period);

  final BudgetPeriodEntity? _period;

  @override
  Future<BudgetPeriodEntity?> readActivePeriod() async => _period;

  @override
  Stream<BudgetPeriodEntity?> watchActivePeriod() =>
      Stream<BudgetPeriodEntity?>.value(_period);

  @override
  Future<void> saveActivePeriod(BudgetPeriodEntity period) async {}

  @override
  Future<void> clearActivePeriod() async {}
}

final class _FixedStock implements IMaterialStockRepository {
  _FixedStock(this._items);

  final List<MaterialStockItemEntity> _items;

  @override
  Future<List<MaterialStockItemEntity>> readAllItems() async =>
      List<MaterialStockItemEntity>.unmodifiable(_items);

  @override
  Future<void> saveAllItems(List<MaterialStockItemEntity> items) async {}

  @override
  Future<void> mergeRemoteStockIfNewer(
    MaterialStockSnapshotEntity remote,
  ) async {}
}
