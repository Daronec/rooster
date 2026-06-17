import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Действие меню «ещё» у строки списка задач на экране «Списки».
enum TaskListItemMenuAction {
  /// Редактирование названия и цвета.
  edit,

  /// Удаление с подтверждением (вызывающий код).
  delete,
}

/// Строка одного пользовательского списка задач на экране «Списки»:
/// цветная полоска слева ([TaskListEntity.colorArgb]), название и меню.
class TaskListItem extends StatelessWidget {
  /// Создаёт строку для [task].
  const TaskListItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    super.key,
  });

  /// Список задач (имя и цвет для полоски).
  final TaskListEntity task;

  /// Открыть экран редактирования по [TaskListEntity.id].
  final void Function(String listId) onEdit;

  /// Запросить удаление [task] (диалог и вызов репозитория — снаружи).
  final void Function(TaskListEntity list) onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final materialScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppSizes.double12),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.white,
        ),
        child: Row(
          children: <Widget>[
            Container(
              height: AppSizes.double48,
              width: AppSizes.double8,
              color: Color(task.colorArgb),
            ),
            const Width(AppSizes.double16),
            Expanded(
              child: Text(
                task.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const Width(AppSizes.double8),
            PopupMenuButton<TaskListItemMenuAction>(
              tooltip: TasksStrings.menuMore(context),
              icon: Icon(
                Icons.more_vert,
                color: materialScheme.onSurfaceVariant,
              ),
              onSelected: (action) {
                switch (action) {
                  case TaskListItemMenuAction.edit:
                    onEdit(task.id);
                  case TaskListItemMenuAction.delete:
                    onDelete(task);
                }
              },
              itemBuilder: (menuContext) {
                return <PopupMenuEntry<TaskListItemMenuAction>>[
                  PopupMenuItem<TaskListItemMenuAction>(
                    value: TaskListItemMenuAction.edit,
                    child: Text(TasksStrings.menuEdit(menuContext)),
                  ),
                  PopupMenuItem<TaskListItemMenuAction>(
                    value: TaskListItemMenuAction.delete,
                    child: Text(TasksStrings.menuDelete(menuContext)),
                  ),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }
}
