import 'package:rooster/features/tasks/domain/entities/task_feasibility_block_detail_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';

/// Результат расчёта выполнимости одной задачи (score + статус + детали блокировки).
final class TaskFeasibilityResultEntity {
  /// Создаёт результат расчёта.
  const TaskFeasibilityResultEntity({
    required this.score,
    required this.status,
    this.detail,
  });

  /// Feasibility score после [IFeasibilityScoringPolicy.clampScore].
  final double score;

  /// Статус доступности.
  final TaskFeasibilityStatusEntity status;

  /// Дополнительные данные при блокировках; null для ready/done.
  final TaskFeasibilityBlockDetailEntity? detail;
}
