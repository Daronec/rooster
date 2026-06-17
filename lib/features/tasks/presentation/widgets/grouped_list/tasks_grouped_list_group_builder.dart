import 'package:flutter/widgets.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_group_view_data.dart';

/// Построитель групп задач по спискам (для UI задач).
final class TasksGroupedListGroupBuilder {
  /// Создаёт построитель.
  const TasksGroupedListGroupBuilder();

  /// Возвращает группы в порядке списков + «сироты» (неизвестные listId).
  List<TasksGroupedListGroupViewData> buildGroups(
    BuildContext context, {
    required List<TaskListEntity> lists,
    required List<TaskEntity> tasks,
  }) {
    final byListId = _tasksByListId(tasks);
    final placed = <String>{};
    final out = <TasksGroupedListGroupViewData>[];

    for (final list in lists) {
      final bucket = byListId[list.id];
      if (bucket == null || bucket.isEmpty) {
        continue;
      }
      placed.add(list.id);
      out.add(
        TasksGroupedListGroupViewData(
          listId: list.id,
          title: list.name,
          colorArgb: list.colorArgb,
          tasks: List<TaskEntity>.from(bucket),
        ),
      );
    }

    final orphanIds = byListId.keys.where((id) => !placed.contains(id)).toList()
      ..sort();
    for (final listId in orphanIds) {
      final bucket = byListId[listId]!;
      out.add(
        TasksGroupedListGroupViewData(
          listId: listId,
          title: TasksStrings.unknownList(context),
          colorArgb: 0xFF8D8D8D,
          tasks: List<TaskEntity>.from(bucket),
        ),
      );
    }

    return out;
  }

  Map<String, List<TaskEntity>> _tasksByListId(List<TaskEntity> tasks) {
    final map = <String, List<TaskEntity>>{};
    for (final task in tasks) {
      map.putIfAbsent(task.listId, () => <TaskEntity>[]).add(task);
    }
    return map;
  }
}

