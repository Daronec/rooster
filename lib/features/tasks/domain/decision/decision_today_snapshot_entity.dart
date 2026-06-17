import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';

/// Результат выборки «Сегодня»: сколько всего ready и видимый срез по лимиту.
final class DecisionTodaySnapshotEntity {
  /// Создаёт снимок.
  const DecisionTodaySnapshotEntity({
    required this.totalReadyCount,
    required this.visibleEntries,
  });

  /// Число задач [TaskFeasibilityStatusEntity.ready] среди pending.
  final int totalReadyCount;

  /// Первые [visibleLimit] записей после сортировки по score.
  final List<TaskFeasibilityListEntryEntity> visibleEntries;
}
