import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity_monetary_total.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/task_detail_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/tasks_list_task_item.dart';
import 'package:rooster/features/tasks/presentation/widgets/task_attachment_preview.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Прокручиваемое тело деталей задачи (общее для mobile/desktop).
class TaskDetailScrollView extends StatelessWidget {
  /// Создаёт виджет.
  const TaskDetailScrollView({
    required this.wm,
    required this.task,
    super.key,
  });

  /// Widget model экрана деталей.
  final TaskDetailScreenWidgetModel wm;

  /// Текущая задача.
  final TaskEntity task;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<TaskListEntity>>(
      valueListenable: wm.listsListenable,
      builder:
          (
            context,
            lists,
            _,
          ) {
            final colorScheme = AppColorScheme.of(context);
            final textScheme = AppTextScheme.of(context);
            final isCompleted = task.status == TaskStatusEntity.completed;
            final listName = wm.listNameFor(task.listId);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        task.title,
                        style: textScheme.body.t20Bold.copyWith(
                          decoration: isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: isCompleted ? colorScheme.gray600 : null,
                        ),
                      ),
                    ),
                    Checkbox(
                      value: isCompleted,
                      onChanged: (checked) {
                        if (checked == null) {
                          return;
                        }
                        wm.onToggleCompleted(task: task, completed: checked);
                      },
                    ),
                  ],
                ),
                const Height(AppSizes.double8),
                Text(
                  isCompleted
                      ? TaskDetailStrings.statusCompleted(context)
                      : TaskDetailStrings.statusPending(context),
                  style: textScheme.body.t14.copyWith(
                    color: colorScheme.gray600,
                  ),
                ),
                const Height(AppSizes.double16),
                _SectionTitle(
                  text: TaskDetailStrings.sectionDescription(context),
                ),
                const Height(AppSizes.double8),
                Text(
                  task.description.isNotEmpty
                      ? task.description
                      : TaskDetailStrings.noDescription(context),
                  style: textScheme.body.t16.copyWith(
                    color: task.description.isEmpty
                        ? colorScheme.gray600
                        : null,
                  ),
                ),
                const Height(AppSizes.double16),
                ValueListenableBuilder<List<TaskEntity>>(
                  valueListenable: wm.dependencyTasksListenable,
                  builder: (context, dependencyTasks, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        _SectionTitle(
                          text: TaskDetailStrings.sectionDependencies(context),
                        ),
                        const Height(AppSizes.double8),
                        if (dependencyTasks.isEmpty)
                          Text(
                            TaskDetailStrings.noDependencies(context),
                            style: textScheme.body.t16.copyWith(
                              color: colorScheme.gray600,
                            ),
                          )
                        else
                          ...dependencyTasks.map(
                            (dependencyTask) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.double8,
                              ),
                              child: _DependencyTaskTile(
                                task: dependencyTask,
                                onTap: () {
                                  wm.onOpenDependencyTask(dependencyTask.id);
                                },
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const Height(AppSizes.double16),
                ValueListenableBuilder<List<TaskEntity>>(
                  valueListenable: wm.subtasksListenable,
                  builder: (context, subtasks, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: _SectionTitle(
                                text: TaskDetailStrings.sectionSubtasks(
                                  context,
                                ),
                              ),
                            ),
                            TextButton.icon(
                              onPressed: wm.onAddSubtask,
                              icon: const Icon(Icons.add),
                              label: Text(
                                TaskDetailStrings.addSubtask(context),
                              ),
                            ),
                          ],
                        ),
                        const Height(AppSizes.double8),
                        if (subtasks.isEmpty)
                          Text(
                            TaskDetailStrings.noSubtasks(context),
                            style: textScheme.body.t16.copyWith(
                              color: colorScheme.gray600,
                            ),
                          )
                        else
                          ...subtasks.map(
                            (subtask) => Padding(
                              padding: const EdgeInsets.only(
                                bottom: AppSizes.double8,
                              ),
                              child: TasksListTaskItem(
                                task: subtask,
                                onEdit: wm.onEditTask,
                                onDelete: wm.onConfirmDeleteSubtask,
                                onToggleCompleted:
                                    (
                                      task, {
                                      required completed,
                                    }) => wm.onToggleCompleted(
                                      task: task,
                                      completed: completed,
                                    ),
                                onTogglePinned: (_) async {},
                                onCancel: (_) async {},
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const Height(AppSizes.double16),
                _SectionTitle(text: TaskDetailStrings.sectionList(context)),
                const Height(AppSizes.double8),
                Text(
                  listName ?? TaskDetailStrings.unknownList(context),
                  style: textScheme.body.t16,
                ),
                const Height(AppSizes.double16),
                _SectionTitle(text: TaskDetailStrings.sectionDue(context)),
                const Height(AppSizes.double8),
                Text(
                  task.dueAt != null
                      ? _formatDate(context, task.dueAt!)
                      : TaskDetailStrings.noDueDate(context),
                  style: textScheme.body.t16,
                ),
                if (!task.isAllDay &&
                    (task.startAt != null || task.endAt != null)) ...<Widget>[
                  const Height(AppSizes.double16),
                  _SectionTitle(text: TaskDetailStrings.sectionTime(context)),
                  const Height(AppSizes.double8),
                  if (task.startAt != null)
                    Text(
                      '${CreateTasksStrings.fieldStartTime(context)}: ${_formatTime(context, task.startAt!)}',
                      style: textScheme.body.t16,
                    ),
                  if (task.endAt != null) ...<Widget>[
                    const Height(AppSizes.double4),
                    Text(
                      '${CreateTasksStrings.fieldEndTime(context)}: ${_formatTime(context, task.endAt!)}',
                      style: textScheme.body.t16,
                    ),
                  ],
                ],
                if (task.isAllDay && task.dueAt != null) ...<Widget>[
                  const Height(AppSizes.double8),
                  Text(
                    CreateTasksStrings.allDay(context),
                    style: textScheme.body.t14.copyWith(
                      color: colorScheme.gray600,
                    ),
                  ),
                ],
                const Height(AppSizes.double16),
                _SectionTitle(
                  text: CreateTasksStrings.sectionPriority(context),
                ),
                const Height(AppSizes.double8),
                Text(
                  CreateTasksStrings.priority(context, task.priority.name),
                  style: textScheme.body.t16,
                ),
                const Height(AppSizes.double16),
                _SectionTitle(
                  text: CreateTasksStrings.sectionReminder(context),
                ),
                const Height(AppSizes.double8),
                Text(
                  CreateTasksStrings.reminderPreset(
                    context,
                    task.reminderPreset.name,
                  ),
                  style: textScheme.body.t16,
                ),
                if (task.reminderPreset == TaskReminderPresetEntity.custom &&
                    task.customReminderAt != null) ...<Widget>[
                  const Height(AppSizes.double4),
                  Text(
                    MaterialLocalizations.of(context).formatFullDate(
                      task.customReminderAt!,
                    ),
                    style: textScheme.body.t14.copyWith(
                      color: colorScheme.gray600,
                    ),
                  ),
                ],
                const Height(AppSizes.double16),
                _SectionTitle(text: TaskDetailStrings.sectionTags(context)),
                const Height(AppSizes.double8),
                Text(
                  task.tags.isNotEmpty
                      ? task.tags.join(', ')
                      : TaskDetailStrings.noTags(context),
                  style: textScheme.body.t16.copyWith(
                    color: task.tags.isEmpty ? colorScheme.gray600 : null,
                  ),
                ),
                const Height(AppSizes.double16),
                _SectionTitle(
                  text: TaskDetailStrings.sectionFinancesAndMaterials(context),
                ),
                const Height(AppSizes.double8),
                Text(
                  '${CreateTasksStrings.fieldEstimatedCost(context)}: '
                  '${_formatDisplayAmount(task.estimatedCost)}',
                  style: textScheme.body.t16,
                ),
                const Height(AppSizes.double4),
                Text(
                  '${TaskDetailStrings.budgetTotal(context)}: '
                  '${_formatDisplayAmount(TaskEntityMonetaryTotal.budgetedAmount(task))}',
                  style: textScheme.body.t14.copyWith(
                    color: colorScheme.gray600,
                  ),
                ),
                const Height(AppSizes.double4),
                Text(
                  TaskDetailStrings.budgetTotalHint(context),
                  style: textScheme.body.t12.copyWith(
                    color: colorScheme.gray600,
                  ),
                ),
                const Height(AppSizes.double12),
                _SectionTitle(
                  text: CreateTasksStrings.sectionMaterials(context),
                ),
                const Height(AppSizes.double8),
                if (task.materialRequirements.isEmpty)
                  Text(
                    TaskDetailStrings.noMaterials(context),
                    style: textScheme.body.t16.copyWith(
                      color: colorScheme.gray600,
                    ),
                  )
                else
                  ...task.materialRequirements.map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: AppSizes.double12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: <Widget>[
                          Text(
                            row.name.trim().isEmpty ? '—' : row.name.trim(),
                            style: textScheme.body.t16,
                          ),
                          const Height(AppSizes.double4),
                          Text(
                            '${CreateTasksStrings.fieldMaterialQuantity(context)}: '
                            '${_formatDisplayAmount(row.requiredQuantity)}  ·  '
                            '${CreateTasksStrings.fieldMaterialCost(context)}: '
                            '${_formatDisplayAmount(row.lineCost)}',
                            style: textScheme.body.t14.copyWith(
                              color: colorScheme.gray600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (task.imageAttachments.isNotEmpty) ...<Widget>[
                  const Height(AppSizes.double16),
                  _SectionTitle(
                    text: CreateTasksStrings.sectionAttachment(context),
                  ),
                  const Height(AppSizes.double8),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      const spacing = AppSizes.double8;
                      final tileSize = (constraints.maxWidth - spacing * 2) / 3;
                      return Wrap(
                        spacing: spacing,
                        runSpacing: spacing,
                        children: [
                          for (final image in task.imageAttachments)
                            SizedBox(
                              width: tileSize,
                              height: tileSize,
                              child: _TaskDetailAttachmentTapTarget(
                                wm: wm,
                                localFilePath: image.localPath,
                                networkImageUrl: image.remoteUrl,
                                child: ClipRRect(
                                  borderRadius: AppSizes.borderRadius8,
                                  child: image.localPath.isNotEmpty
                                      ? taskAttachmentPreview(
                                          image.localPath,
                                          size: tileSize,
                                        )
                                      : Image.network(
                                          image.remoteUrl ?? '',
                                          width: tileSize,
                                          height: tileSize,
                                          fit: BoxFit.cover,
                                          errorBuilder: (_, __, ___) => Icon(
                                            Icons.broken_image_outlined,
                                            size: AppSizes.double48,
                                            color: colorScheme.gray500,
                                          ),
                                        ),
                                ),
                              ),
                            ),
                        ],
                      );
                    },
                  ),
                ],
              ],
            );
          },
    );
  }
}

String _formatDate(BuildContext context, DateTime date) {
  return MaterialLocalizations.of(context).formatFullDate(date.toLocal());
}

String _formatDisplayAmount(double value) {
  if (value.isNaN) {
    return '—';
  }
  if (value == 0) {
    return '0';
  }
  final text = value.toString();
  if (!text.contains('.')) {
    return text;
  }
  return text.replaceFirst(RegExp(r'\.?0+$'), '');
}

String _formatTime(BuildContext context, DateTime dateTime) {
  return TimeOfDay.fromDateTime(dateTime.toLocal()).format(context);
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    return Text(
      text,
      style: textScheme.body.t14Medium,
    );
  }
}

class _DependencyTaskTile extends StatelessWidget {
  const _DependencyTaskTile({
    required this.task,
    required this.onTap,
  });

  final TaskEntity task;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    final isCompleted = task.status == TaskStatusEntity.completed;
    return Material(
      color: colorScheme.gray100,
      borderRadius: AppSizes.borderRadius8,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppSizes.borderRadius8,
        child: Padding(
          padding: AppSizes.edgeInsetsAll16,
          child: Row(
            children: <Widget>[
              Icon(
                isCompleted
                    ? Icons.check_circle_outline
                    : Icons.radio_button_unchecked,
                color: isCompleted ? colorScheme.green : colorScheme.warning,
              ),
              const Width(AppSizes.double12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      task.title,
                      style: textScheme.body.t16Medium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Height(AppSizes.double4),
                    Text(
                      isCompleted
                          ? TaskDetailStrings.dependencyCompleted(context)
                          : TaskDetailStrings.dependencyPending(context),
                      style: textScheme.body.t12.copyWith(
                        color: colorScheme.gray600,
                      ),
                    ),
                  ],
                ),
              ),
              const Width(AppSizes.double8),
              Icon(
                Icons.chevron_right,
                color: colorScheme.gray600,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TaskDetailAttachmentTapTarget extends StatelessWidget {
  const _TaskDetailAttachmentTapTarget({
    required this.wm,
    required this.localFilePath,
    required this.networkImageUrl,
    required this.child,
  });

  final TaskDetailScreenWidgetModel wm;
  final String? localFilePath;
  final String? networkImageUrl;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: TaskDetailStrings.openFullscreenSemantics(context),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () {
            wm.onOpenTaskAttachmentFullscreen(
              localFilePath: localFilePath,
              networkImageUrl: networkImageUrl,
            );
          },
          borderRadius: BorderRadius.circular(AppSizes.double8),
          child: child,
        ),
      ),
    );
  }
}
