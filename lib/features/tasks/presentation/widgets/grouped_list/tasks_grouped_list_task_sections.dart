import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/tasks_list_task_item.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Секции задач в группе: «Не выполнено» и «Выполнено».
final class TasksGroupedListTaskSections extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListTaskSections({
    required this.wm,
    required this.tasks,
    super.key,
  });

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  /// Задачи группы.
  final List<TaskEntity> tasks;

  @override
  Widget build(BuildContext context) {
    final incompleteTasks = tasks
        .where((task) => task.status == TaskStatusEntity.pending)
        .toList(growable: false);
    final completedTasks = tasks
        .where(
          (task) =>
              task.status == TaskStatusEntity.completed ||
              task.status == TaskStatusEntity.cancelled,
        )
        .toList(growable: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        if (incompleteTasks.isNotEmpty) ...<Widget>[
          TasksGroupedListSectionTitle(
            title: TasksStrings.sectionNotCompleted(context),
          ),
          TasksGroupedListTaskItems(
            wm: wm,
            tasks: incompleteTasks,
          ),
        ],
        if (completedTasks.isNotEmpty) ...<Widget>[
          if (incompleteTasks.isNotEmpty)
            const Height(AppSizes.double16),
          TasksGroupedListSectionTitle(
            title: TasksStrings.sectionCompleted(context),
          ),
          TasksGroupedListTaskItems(
            wm: wm,
            tasks: completedTasks,
          ),
        ],
      ],
    );
  }
}

/// Заголовок секции внутри группы задач.
final class TasksGroupedListSectionTitle extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListSectionTitle({required this.title, super.key});

  /// Текст заголовка.
  final String title;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    final colorScheme = AppColorScheme.of(context);
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSizes.double8,
        left: AppSizes.double16,
      ),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: textScheme.body.t14Medium.copyWith(
            color: colorScheme.gray600,
          ),
        ),
      ),
    );
  }
}

/// Список элементов задач внутри секции.
final class TasksGroupedListTaskItems extends StatelessWidget {
  /// Создаёт виджет.
  const TasksGroupedListTaskItems({
    required this.wm,
    required this.tasks,
    super.key,
  });

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  /// Задачи секции.
  final List<TaskEntity> tasks;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List<Widget>.generate(tasks.length, (index) {
        final task = tasks[index];
        return Padding(
          padding: EdgeInsets.only(
            top: index == 0 ? 0 : AppSizes.double8,
            bottom: AppSizes.double8,
          ),
          child: TasksListTaskItem(
            task: task,
            onEdit: wm.onEditTask,
            onDelete: wm.onConfirmDeleteTask,
            onToggleCompleted: wm.onToggleTaskCompleted,
            onTogglePinned: wm.onTogglePinned,
            onCancel: wm.onCancelTask,
          ),
        );
      }, growable: false),
    );
  }
}
