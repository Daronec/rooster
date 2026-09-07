import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_group_view_data.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_task_sections.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// Тайл одной группы задач (ExpansionTile списка).
final class TasksGroupedListGroupTile extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListGroupTile({
    required this.wm,
    required this.group,
    required this.isExpanded,
    required this.shape,
    super.key,
  });

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  /// Данные группы.
  final TasksGroupedListGroupViewData group;

  /// Флаг развёрнутости.
  final bool isExpanded;

  /// Общая форма контейнеров списка.
  final SmoothRectangleBorder shape;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.double8),
      child: ExpansionTile(
        key: ValueKey<String>('${group.listId}_$isExpanded'),
        maintainState: true,
        initiallyExpanded: isExpanded,
        backgroundColor: colorScheme.white,
        collapsedBackgroundColor: colorScheme.white,
        shape: shape,
        collapsedShape: shape,
        onExpansionChanged: (expanded) {
          wm.onTaskListGroupExpansionChanged(
            listId: group.listId,
            expanded: expanded,
          );
        },
        leading: CircleAvatar(
          radius: AppSizes.double8,
          backgroundColor: Color(group.colorArgb),
        ),
        title: Text(
          group.title,
          style: textScheme.body.t16Medium,
        ),
        subtitle: Text(
          TasksStrings.groupTaskCount(context, count: group.tasks.length),
          style: textScheme.body.t12.copyWith(
            color: colorScheme.gray600,
          ),
        ),
        children: <Widget>[
          TasksGroupedListTaskSections(
            wm: wm,
            tasks: group.tasks,
          ),
        ],
      ),
    );
  }
}


