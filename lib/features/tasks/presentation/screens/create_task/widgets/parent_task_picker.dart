import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';

/// Выбор родительской задачи: кнопка добавления или плитка выбранной задачи.
final class ParentTaskPicker extends StatelessWidget {
  /// Создаёт виджет.
  const ParentTaskPicker({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final parentId = wm.formState.parentTaskId;
    final title = wm.taskTitleById(parentId);
    final hasParent =
        parentId != null &&
        parentId.isNotEmpty &&
        title != null &&
        title.isNotEmpty;

    if (!hasParent) {
      return AppPrimaryButton(
        onPressed: wm.onPickParentTask,
        child: Text(CreateTasksStrings.addParentTask(context)),
      );
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => wm.onEditTask(parentId),
    );
  }
}
