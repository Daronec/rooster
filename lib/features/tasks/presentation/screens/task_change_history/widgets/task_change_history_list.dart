import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';
import 'package:rooster/features/tasks/presentation/strings/task_change_history_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Список истории изменений задачи (общий для mobile/desktop).
class TaskChangeHistoryList extends StatelessWidget {
  /// Создаёт виджет.
  const TaskChangeHistoryList({required this.items, super.key});

  /// Записи истории.
  final List<TaskChangeEntity> items;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      final textScheme = AppTextScheme.of(context);
      final colorScheme = AppColorScheme.of(context);
      return Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Text(
          TaskChangeHistoryStrings.emptyState(context),
          style: textScheme.body.t16.copyWith(color: colorScheme.gray600),
        ),
      );
    }

    return ListView.separated(
      padding: AppSizes.edgeInsetsAll16,
      itemCount: items.length,
      separatorBuilder: (_, __) => const Height(AppSizes.double12),
      itemBuilder: (context, index) {
        final change = items[index];
        return _TaskChangeTile(change: change);
      },
    );
  }
}

class _TaskChangeTile extends StatelessWidget {
  const _TaskChangeTile({required this.change});

  final TaskChangeEntity change;

  @override
  Widget build(BuildContext context) {
    final textScheme = AppTextScheme.of(context);
    final colorScheme = AppColorScheme.of(context);
    final kindLabel = switch (change.kind) {
      TaskChangeKindEntity.created => TaskChangeHistoryStrings.kindCreated(
        context,
      ),
      TaskChangeKindEntity.updated => TaskChangeHistoryStrings.kindUpdated(
        context,
      ),
      TaskChangeKindEntity.deleted => TaskChangeHistoryStrings.kindDeleted(
        context,
      ),
    };

    final dt = DateTime.fromMillisecondsSinceEpoch(
      change.changedAtMillis,
    ).toLocal();
    final dateText = MaterialLocalizations.of(context).formatFullDate(dt);
    final timeText = TimeOfDay.fromDateTime(dt).format(context);
    final authorName = change.authorNameSnapshot.trim();
    final authorText = TaskChangeHistoryStrings.authorLine(
      context,
      author: authorName.isEmpty
          ? TaskChangeHistoryStrings.unknownAuthor(context)
          : authorName,
    );

    final fieldsText =
        change.kind == TaskChangeKindEntity.updated &&
            change.changedFields.isNotEmpty
        ? TaskChangeHistoryStrings.updatedFields(
            context,
            fields: change.changedFields
                .map((field) => _fieldLabel(context, field))
                .join(', '),
          )
        : null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: AppSizes.borderRadius12,
        border: Border.all(color: colorScheme.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.double12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              kindLabel,
              style: textScheme.body.t16Medium,
            ),
            const Height(AppSizes.double4),
            Text(
              '$dateText · $timeText',
              style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
            ),
            const Height(AppSizes.double4),
            Text(
              authorText,
              style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
            ),
            if (fieldsText != null) ...<Widget>[
              const Height(AppSizes.double8),
              Text(
                fieldsText,
                style: textScheme.body.t14.copyWith(color: colorScheme.gray700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _fieldLabel(BuildContext context, TaskChangeFieldEntity field) {
    return switch (field) {
      TaskChangeFieldEntity.title => TaskChangeHistoryStrings.fieldTitle(
        context,
      ),
      TaskChangeFieldEntity.description =>
        TaskChangeHistoryStrings.fieldDescription(context),
      TaskChangeFieldEntity.list => TaskChangeHistoryStrings.fieldList(context),
      TaskChangeFieldEntity.parentTask =>
        TaskChangeHistoryStrings.fieldParentTask(context),
      TaskChangeFieldEntity.executor => TaskChangeHistoryStrings.fieldExecutor(
        context,
      ),
      TaskChangeFieldEntity.observer => TaskChangeHistoryStrings.fieldObserver(
        context,
      ),
      TaskChangeFieldEntity.dueDate => TaskChangeHistoryStrings.fieldDueDate(
        context,
      ),
      TaskChangeFieldEntity.time => TaskChangeHistoryStrings.fieldTime(context),
      TaskChangeFieldEntity.priority => TaskChangeHistoryStrings.fieldPriority(
        context,
      ),
      TaskChangeFieldEntity.tags => TaskChangeHistoryStrings.fieldTags(context),
      TaskChangeFieldEntity.status => TaskChangeHistoryStrings.fieldStatus(
        context,
      ),
      TaskChangeFieldEntity.estimatedCost =>
        TaskChangeHistoryStrings.fieldEstimatedCost(context),
      TaskChangeFieldEntity.materials =>
        TaskChangeHistoryStrings.fieldMaterials(context),
      TaskChangeFieldEntity.attachment =>
        TaskChangeHistoryStrings.fieldAttachment(context),
    };
  }
}
