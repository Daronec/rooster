import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';

/// Данные для UI экрана «Сегодня».
final class DecisionTodayViewData {
  /// Создаёт данные.
  const DecisionTodayViewData({
    required this.totalReadyCount,
    required this.visibleEntries,
    required this.visibleLimit,
  });

  /// Сколько всего задач в статусе ready.
  final int totalReadyCount;

  /// Текущая видимая порция.
  final List<TaskFeasibilityListEntryEntity> visibleEntries;

  /// Лимит, с которым строилась выборка.
  final int visibleLimit;

  /// Есть ли ещё задачи за пределами [visibleEntries].
  bool get canShowMore => visibleEntries.length < totalReadyCount;
}
