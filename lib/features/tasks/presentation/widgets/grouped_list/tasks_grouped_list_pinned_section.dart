import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/grouped_list/tasks_grouped_list_task_sections.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:smooth_corner/smooth_corner.dart';

/// Блок закреплённых задач.
final class TasksGroupedListPinnedSection extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListPinnedSection({
    required this.wm,
    required this.tasks,
    required this.shape,
    super.key,
  });

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  /// Закреплённые задачи.
  final List<TaskEntity> tasks;

  /// Общая форма контейнеров списка.
  final SmoothRectangleBorder shape;

  @override
  Widget build(BuildContext context) {
    if (tasks.isEmpty) {
      return const SizedBox.shrink();
    }
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.double8),
      child: Material(
        color: colorScheme.white,
        shape: shape,
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.double16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                TasksStrings.pinnedGroupTitle(context),
                style: textScheme.body.t16Medium,
              ),
              const Height(AppSizes.double12),
              TasksGroupedListTaskSections(
                wm: wm,
                tasks: tasks,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

