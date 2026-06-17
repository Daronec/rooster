import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Суммарная денежная нагрузка задачи на бюджет.
///
/// Важно: стоимость материалов **уже входит** в [TaskEntity.estimatedCost],
/// поэтому здесь возвращается только `estimatedCost` (неотрицательное).
abstract final class TaskEntityMonetaryTotal {
  /// Сумма для проверки бюджета.
  static double budgetedAmount(TaskEntity task) {
    final cost = task.estimatedCost;
    if (cost.isNaN || cost < 0) {
      return 0;
    }
    return cost;
  }
}
