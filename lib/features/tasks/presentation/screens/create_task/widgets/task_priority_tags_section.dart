import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Блок приоритета и тегов.
final class TaskPriorityTagsSection extends StatelessWidget {
  /// Создаёт блок.
  const TaskPriorityTagsSection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  static const List<TaskPriorityEntity> _priorityChoices = <TaskPriorityEntity>[
    TaskPriorityEntity.none,
    TaskPriorityEntity.low,
    TaskPriorityEntity.normal,
    TaskPriorityEntity.high,
    TaskPriorityEntity.urgent,
  ];

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return ValueListenableBuilder<String?>(
      valueListenable: wm.formState.priorityListenable,
      builder: (context, selectedId, _) {
        final selected = _parsePriorityOrDefault(selectedId);
        final flagColor = _colorForPriority(colorScheme, selected);
        return Row(
          children: <Widget>[
            PopupMenuButton<TaskPriorityEntity>(
              tooltip: CreateTasksStrings.sectionPriority(context),
              onSelected: wm.formState.setPriority,
              itemBuilder: (context) {
                return _priorityChoices
                    .map(
                      (priority) => PopupMenuItem<TaskPriorityEntity>(
                        value: priority,
                        child: Row(
                          children: <Widget>[
                            Icon(
                              Icons.flag,
                              size: AppSizes.double16,
                              color: _colorForPriority(colorScheme, priority),
                            ),
                            const Width(AppSizes.double8),
                            Expanded(
                              child: Text(
                                CreateTasksStrings.priority(
                                  context,
                                  priority.name,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                    .toList(growable: false);
              },
              child: _PriorityFlagButton(color: flagColor),
            ),
          ],
        );
      },
    );
  }

  TaskPriorityEntity _parsePriorityOrDefault(String? id) {
    if (id == null || id.isEmpty) {
      return TaskPriorityEntity.normal;
    }
    return TaskPriorityEntity.values.firstWhere(
      (priority) => priority.name == id,
      orElse: () => TaskPriorityEntity.normal,
    );
  }

  Color _colorForPriority(AppColorScheme scheme, TaskPriorityEntity priority) {
    return switch (priority) {
      TaskPriorityEntity.none => scheme.gray400,
      TaskPriorityEntity.low => scheme.green,
      TaskPriorityEntity.normal => scheme.primaryNormal,
      TaskPriorityEntity.high => scheme.warning,
      TaskPriorityEntity.urgent => scheme.red,
    };
  }
}

final class _PriorityFlagButton extends StatelessWidget {
  const _PriorityFlagButton({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.flag,
      size: AppSizes.double20,
      color: color,
    );
  }
}
