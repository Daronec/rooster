import 'package:rooster/features/tasks/domain/entities/task_feasibility_block_detail_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';

/// Результат разрешения статуса выполнимости (без числового score).
final class TaskFeasibilityResolutionEntity {
  /// Создаёт значение разрешения.
  const TaskFeasibilityResolutionEntity({
    required this.status,
    this.detail,
  });

  /// Итоговый статус.
  final TaskFeasibilityStatusEntity status;

  /// Данные для UI / i18n; null для [TaskFeasibilityStatusEntity.ready] и [TaskFeasibilityStatusEntity.done].
  final TaskFeasibilityBlockDetailEntity? detail;
}
