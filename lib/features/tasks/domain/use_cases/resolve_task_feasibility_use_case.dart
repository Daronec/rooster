import 'package:rooster/features/tasks/domain/decision/calculate_task_feasibility.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_result_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';

/// Оркестратор: загрузка бюджета/склада + вызов чистого [CalculateTaskFeasibility] (D3-01).
final class ResolveTaskFeasibilityUseCase {
  /// DI: репозитории и калькулятор.
  ResolveTaskFeasibilityUseCase({
    required IBudgetRepository budgetRepository,
    required IMaterialStockRepository materialStockRepository,
    required CalculateTaskFeasibility feasibilityCalculator,
  })  : _budgetRepository = budgetRepository,
        _materialStockRepository = materialStockRepository,
        _feasibilityCalculator = feasibilityCalculator;

  final IBudgetRepository _budgetRepository;
  final IMaterialStockRepository _materialStockRepository;
  final CalculateTaskFeasibility _feasibilityCalculator;

  /// [tasksById] — снимок всех задач для разрешения зависимостей; [taskId] должен присутствовать в карте.
  Future<TaskFeasibilityResultEntity?> execute({
    required String taskId,
    required Map<String, TaskEntity> tasksById,
  }) async {
    final task = tasksById[taskId];
    if (task == null) {
      return null;
    }
    final budget = await _budgetRepository.readActivePeriod();
    final stockItems = await _materialStockRepository.readAllItems();
    return _feasibilityCalculator.execute(
      task: task,
      tasksById: tasksById,
      stockItems: stockItems,
      budget: budget,
    );
  }
}
