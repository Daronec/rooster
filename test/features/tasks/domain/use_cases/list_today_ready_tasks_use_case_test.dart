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

void main() {
  test('только pending + ready, лимит по умолчанию 3', () async {
    final budget = _MemoryBudget(
      const BudgetPeriodEntity(
        year: 2026,
        month: 1,
        amountLimit: 1000,
      ),
    );
    final stock = _MemoryStock(const []);
    final useCase = ListTodayReadyTasksUseCase(
      budgetRepository: budget,
      materialStockRepository: stock,
      feasibilityCalculator: CalculateTaskFeasibility(
        policy: const DefaultFeasibilityScoringPolicy(),
      ),
    );

    final tasksById = <String, TaskEntity>{
      for (var index = 0; index < 5; index++)
        't$index': TaskEntity(
          id: 't$index',
          listId: 'l',
          title: 'Task $index',
          updatedAtMillis: index,
          importance: index,
        ),
    };

    final today = await useCase.execute(tasksById: tasksById);
    expect(today.length, 3);
    for (final entry in today) {
      expect(entry.feasibility.status, TaskFeasibilityStatusEntity.ready);
      expect(entry.task.status, TaskStatusEntity.pending);
    }
  });

  test('completed не попадает в выборку', () async {
    final budget = _MemoryBudget(
      const BudgetPeriodEntity(year: 2026, month: 1, amountLimit: 100),
    );
    final stock = _MemoryStock(const []);
    final useCase = ListTodayReadyTasksUseCase(
      budgetRepository: budget,
      materialStockRepository: stock,
      feasibilityCalculator: CalculateTaskFeasibility(
        policy: const DefaultFeasibilityScoringPolicy(),
      ),
    );

    final tasksById = <String, TaskEntity>{
      'done': const TaskEntity(
        id: 'done',
        listId: 'l',
        title: 'Done',
        updatedAtMillis: 2,
        status: TaskStatusEntity.completed,
      ),
      'open': const TaskEntity(
        id: 'open',
        listId: 'l',
        title: 'Open',
        updatedAtMillis: 1,
      ),
    };

    final today = await useCase.execute(tasksById: tasksById);
    expect(today.length, 1);
    expect(today.single.task.id, 'open');
  });
}

final class _MemoryBudget implements IBudgetRepository {
  _MemoryBudget(this._period);

  BudgetPeriodEntity? _period;

  @override
  Future<BudgetPeriodEntity?> readActivePeriod() async => _period;

  @override
  Stream<BudgetPeriodEntity?> watchActivePeriod() =>
      Stream<BudgetPeriodEntity?>.value(_period);

  @override
  Future<void> saveActivePeriod(BudgetPeriodEntity period) async {
    _period = period;
  }

  @override
  Future<void> clearActivePeriod() async {
    _period = null;
  }
}

final class _MemoryStock implements IMaterialStockRepository {
  _MemoryStock(this._items);

  List<MaterialStockItemEntity> _items;

  @override
  Future<List<MaterialStockItemEntity>> readAllItems() async =>
      List<MaterialStockItemEntity>.unmodifiable(_items);

  @override
  Future<void> saveAllItems(List<MaterialStockItemEntity> items) async {
    _items = List<MaterialStockItemEntity>.from(items);
  }

  @override
  Future<void> mergeRemoteStockIfNewer(
    MaterialStockSnapshotEntity remote,
  ) async {}
}
