import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart'
    show TasksScreenWidgetModel;
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/task_priority_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Действие из меню «ещё» у элемента задачи в списке.
enum TasksListTaskItemMenuAction {
  /// Закрепить / открепить.
  pin,

  /// Отменить задачу («Не буду делать»).
  cancel,

  /// Удаление с подтверждением (вызывающий код).
  delete,
}

/// Карточка задачи в списке: заголовок, описание, меню «ещё».
class TasksListTaskItem extends StatelessWidget {
  /// Создаёт элемент списка.
  const TasksListTaskItem({
    required this.task,
    required this.onEdit,
    required this.onDelete,
    required this.onToggleCompleted,
    required this.onTogglePinned,
    required this.onCancel,
    super.key,
  });

  /// Данные задачи.
  final TaskEntity task;

  /// Редактирование (тот же экран, что и создание).
  final void Function(String taskId) onEdit;

  /// Удаление (после подтверждения в [TasksScreenWidgetModel]).
  final void Function(TaskEntity task) onDelete;

  /// Смена признака «выполнена»; [completed] — новое значение чекбокса.
  final Future<void> Function(TaskEntity task, {required bool completed})
  onToggleCompleted;

  /// Закрепить/открепить задачу.
  final Future<void> Function(TaskEntity task) onTogglePinned;

  /// Отметить задачу как отменённую.
  final Future<void> Function(TaskEntity task) onCancel;

  @override
  Widget build(BuildContext context) {
    final isCompleted = task.status == TaskStatusEntity.completed;
    final isCancelled = task.status == TaskStatusEntity.cancelled;
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    final titleStyle = textScheme.body.t16Medium.copyWith(
      decoration: (isCompleted || isCancelled)
          ? TextDecoration.lineThrough
          : null,
      color: (isCompleted || isCancelled) ? colorScheme.gray600 : null,
    );
    final priorityChip = _PriorityChip.tryBuild(
      context: context,
      priority: task.priority,
      isCompleted: isCompleted || isCancelled,
    );
    final relativeDueChip = _RelativeDueChip.tryBuild(
      context: context,
      dueAt: task.dueAt,
    );
    return Padding(
      padding: const EdgeInsets.only(left: AppSizes.double16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: <Widget>[
              Semantics(
                label: isCancelled
                    ? TasksStrings.checkboxMarkPending(context)
                    : isCompleted
                    ? TasksStrings.checkboxMarkPending(context)
                    : TasksStrings.checkboxMarkCompleted(context),
                child: _TaskStatusToggle(
                  status: task.status,
                  onToggleCompleted: (completed) =>
                      onToggleCompleted(task, completed: completed),
                ),
              ),
              const Width(AppSizes.double4),
              Expanded(
                child: InkWell(
                  onTap: () => onEdit(task.id),
                  child: Text(
                    task.title,
                    style: titleStyle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              const Width(AppSizes.double8),
              PopupMenuButton<TasksListTaskItemMenuAction>(
                tooltip: TasksStrings.menuMore(context),
                icon: Icon(
                  Icons.more_vert,
                  color: colorScheme.gray600,
                ),
                onSelected: (action) {
                  switch (action) {
                    case TasksListTaskItemMenuAction.pin:
                      onTogglePinned(task);
                    case TasksListTaskItemMenuAction.cancel:
                      onCancel(task);
                    case TasksListTaskItemMenuAction.delete:
                      onDelete(task);
                  }
                },
                itemBuilder: (context) {
                  return <PopupMenuEntry<TasksListTaskItemMenuAction>>[
                    PopupMenuItem<TasksListTaskItemMenuAction>(
                      value: TasksListTaskItemMenuAction.pin,
                      child: Text(
                        task.isPinned
                            ? TasksStrings.menuUnpin(context)
                            : TasksStrings.menuPin(context),
                      ),
                    ),
                    PopupMenuItem<TasksListTaskItemMenuAction>(
                      value: TasksListTaskItemMenuAction.cancel,
                      child: Text(TasksStrings.menuCancel(context)),
                    ),
                    PopupMenuItem<TasksListTaskItemMenuAction>(
                      value: TasksListTaskItemMenuAction.delete,
                      child: Text(TasksStrings.menuDelete(context)),
                    ),
                  ];
                },
              ),
            ],
          ),
          Row(
            children: [
              ?priorityChip,
              if (priorityChip != null) const Width(AppSizes.double8),
              relativeDueChip ?? const SizedBox(),
            ],
          ),
          if (task.tags.isNotEmpty) ...<Widget>[
            const Height(AppSizes.double6),
            _TaskTagsWrap(tags: task.tags),
          ],
        ],
      ),
    );
  }
}

final class _TaskStatusToggle extends StatelessWidget {
  const _TaskStatusToggle({
    required this.status,
    required this.onToggleCompleted,
  });

  final TaskStatusEntity status;
  final ValueChanged<bool> onToggleCompleted;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final isCompleted = status == TaskStatusEntity.completed;
    final isCancelled = status == TaskStatusEntity.cancelled;
    const size = AppSizes.double24;

    final Color borderColor;
    final Color backgroundColor;
    final Widget? icon;

    if (isCompleted) {
      borderColor = colorScheme.green;
      backgroundColor = colorScheme.green.withAlpha(36);
      icon = Icon(
        Icons.check,
        size: AppSizes.double16,
        color: colorScheme.green,
      );
    } else if (isCancelled) {
      borderColor = colorScheme.red;
      backgroundColor = colorScheme.red.withAlpha(36);
      icon = Icon(
        Icons.close,
        size: AppSizes.double16,
        color: colorScheme.red,
      );
    } else {
      borderColor = colorScheme.gray400;
      backgroundColor = colorScheme.white;
      icon = null;
    }

    return InkWell(
      borderRadius: AppSizes.borderRadius8,
      onTap: isCancelled ? null : () => onToggleCompleted(!isCompleted),
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: AppSizes.borderRadius8,
            border: Border.all(color: borderColor),
          ),
          child: Center(child: icon),
        ),
      ),
    );
  }
}

final class _TaskTagsWrap extends StatelessWidget {
  const _TaskTagsWrap({required this.tags});

  final List<String> tags;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: AppSizes.double6,
      runSpacing: AppSizes.double4,
      children: tags
          .where((tag) => tag.trim().isNotEmpty)
          .map((tag) => _TaskTagChip(text: tag.trim()))
          .toList(growable: false),
    );
  }
}

final class _TaskTagChip extends StatelessWidget {
  const _TaskTagChip({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.gray100,
        borderRadius: AppSizes.borderRadius8,
        border: Border.all(color: colorScheme.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.double6,
          vertical: AppSizes.double2,
        ),
        child: Text(
          '#$text',
          style: textScheme.body.t10Medium.copyWith(color: colorScheme.gray700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

final class _RelativeDueChip extends StatelessWidget {
  const _RelativeDueChip({required this.text});

  static Widget? tryBuild({
    required BuildContext context,
    required DateTime? dueAt,
  }) {
    if (dueAt == null) {
      return null;
    }
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final dueLocal = dueAt.toLocal();
    final dueDate = DateTime(dueLocal.year, dueLocal.month, dueLocal.day);
    final daysDiff = dueDate.difference(todayDate).inDays;
    final text = switch (daysDiff) {
      0 => TasksStrings.dueToday(context),
      -1 => TasksStrings.dueYesterday(context),
      1 => TasksStrings.dueTomorrow(context),
      _ => null,
    };
    if (text == null) {
      return null;
    }
    return _RelativeDueChip(text: text);
  }

  final String text;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.gray200,
        borderRadius: AppSizes.borderRadius8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.double6,
          vertical: AppSizes.double2,
        ),
        child: Text(
          text,
          style: textScheme.body.t10Medium.copyWith(color: colorScheme.gray700),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}

final class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.backgroundColor,
    required this.textColor,
    required this.text,
  });

  static Widget? tryBuild({
    required BuildContext context,
    required TaskPriorityEntity priority,
    required bool isCompleted,
  }) {
    if (isCompleted) {
      return null;
    }
    if (priority == TaskPriorityEntity.none ||
        priority == TaskPriorityEntity.normal) {
      return null;
    }
    final colorScheme = AppColorScheme.of(context);
    final (backgroundColor, textColor) = switch (priority) {
      TaskPriorityEntity.low => (colorScheme.gray200, colorScheme.gray700),
      TaskPriorityEntity.high => (
        colorScheme.warning.withAlpha(36),
        colorScheme.warning,
      ),
      TaskPriorityEntity.urgent => (
        colorScheme.red.withAlpha(36),
        colorScheme.red,
      ),
      _ => (colorScheme.gray200, colorScheme.gray700),
    };
    return _PriorityChip(
      backgroundColor: backgroundColor,
      textColor: textColor,
      text: TaskPriorityStrings.label(context, priority),
    );
  }

  final Color backgroundColor;
  final Color textColor;
  final String text;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: AppSizes.borderRadius8,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.double6,
          vertical: AppSizes.double2,
        ),
        child: Text(
          text,
          style: textScheme.body.t10Medium.copyWith(color: textColor),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}
