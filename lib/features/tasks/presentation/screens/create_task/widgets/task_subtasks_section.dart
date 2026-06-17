import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/tasks_list_task_item.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Блок подзадач при редактировании задачи: список, добавление, переход к редактированию.
final class TaskSubtasksSection extends StatelessWidget {
  /// Создаёт блок.
  const TaskSubtasksSection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Height(AppSizes.double16),
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                CreateTasksStrings.sectionSubtasks(context),
                style: AppTextStyle.t14Medium.value,
              ),
            ),
            TextButton.icon(
              onPressed: wm.onAddSubtask,
              icon: const Icon(Icons.add),
              label: Text(CreateTasksStrings.addSubtask(context)),
            ),
          ],
        ),
        ValueListenableBuilder<List<TaskEntity>>(
          valueListenable: wm.subtasksListenable,
          builder: (context, subtasks, _) {
            if (subtasks.isEmpty) {
              return const SizedBox();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Height(AppSizes.double8),
                ...subtasks.map(
                  (subtask) => Padding(
                    padding: const EdgeInsets.only(
                      bottom: AppSizes.double8,
                    ),
                    child: TasksListTaskItem(
                      task: subtask,
                      onEdit: wm.onEditTask,
                      onDelete: wm.onConfirmDeleteSubtask,
                      onToggleCompleted: wm.onToggleTaskCompleted,
                      onTogglePinned: (_) async {},
                      onCancel: (_) async {},
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}
