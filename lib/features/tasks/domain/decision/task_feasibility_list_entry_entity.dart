import 'package:rooster/features/tasks/domain/decision/task_feasibility_result_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Задача вместе с результатом расчёта выполнимости (списки «Сегодня» / «Заблокировано»).
final class TaskFeasibilityListEntryEntity {
  /// Создаёт элемент списка.
  const TaskFeasibilityListEntryEntity({
    required this.task,
    required this.feasibility,
  });

  /// Задача.
  final TaskEntity task;

  /// Результат движка решений.
  final TaskFeasibilityResultEntity feasibility;
}
