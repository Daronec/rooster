import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_empty_state.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_group_builder.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_group_tile.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_pinned_section.dart';
import 'package:rooster/util/value_listenable_builder/trio_listenable_builder.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// Список задач, сгруппированный по спискам с раскрытием групп.
class TasksGroupedListBody extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListBody({required this.wm, super.key});

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return TrioListenableBuilder<
      List<TaskEntity>,
      List<TaskListEntity>,
      Set<String>
    >(
      firstListenable: wm.unpinnedTasksListenable,
      secondListenable: wm.taskListsListenable,
      thirdListenable: wm.expandedListIdsListenable,
      builder:
          (
            context,
            tasks,
            lists,
            expandedListIds,
            _,
          ) {
            final pinnedTasks = wm.pinnedTasksListenable.value;
            final unpinnedTasks = tasks;
            if (pinnedTasks.isEmpty && unpinnedTasks.isEmpty) {
              return const TasksGroupedListEmptyState();
            }
            final groups = const TasksGroupedListGroupBuilder().buildGroups(
              context,
              lists: lists,
              tasks: unpinnedTasks,
            );
            final shape = SmoothRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.double16),
              smoothness: 1,
            );
            return ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                TasksGroupedListPinnedSection(
                  wm: wm,
                  tasks: pinnedTasks,
                  shape: shape,
                ),
                ...groups.map((group) {
                  final expanded = expandedListIds.contains(group.listId);
                  return TasksGroupedListGroupTile(
                    wm: wm,
                    group: group,
                    isExpanded: expanded,
                    shape: shape,
                  );
                }),
              ],
            );
          },
    );
  }
}
