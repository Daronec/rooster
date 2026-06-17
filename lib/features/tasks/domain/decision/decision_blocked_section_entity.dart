import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';

/// Группа заблокированных задач по типу блокировки.
final class DecisionBlockedSectionEntity {
  /// Создаёт секцию.
  const DecisionBlockedSectionEntity({
    required this.status,
    required this.entries,
  });

  /// Тип блокировки (без ready/done).
  final TaskFeasibilityStatusEntity status;

  /// Задачи в группе.
  final List<TaskFeasibilityListEntryEntity> entries;
}
