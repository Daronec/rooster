import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_tags_field.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/parent_task_picker.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_list_picker.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_due_date_section.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_reminder_section.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_recurring_reminder_section.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_subtasks_section.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_estimated_cost_field.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/material_requirements_block.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_attachment_section.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/task_importance_complexity_section.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/create_task_action_panel.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';
import 'package:rooster/util/extensions/value_notifier_x.dart';
import 'package:rooster/util/union_state/union_state_list_body.dart';

/// Форма создания/редактирования задачи (общая вёрстка для mobile и desktop).
class CreateTaskFormScaffold extends StatelessWidget {
  /// Создаёт виджет.
  const CreateTaskFormScaffold({
    required this.wm,
    required this.listsLoadingBuilder,
    required this.listsFailureBuilder,
    super.key,
  });

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  /// Ветка загрузки списков в [UnionStateListBody] (платформенный виджет).
  final Widget Function(
    BuildContext context,
    List<TaskListEntity>? cached,
  )
  listsLoadingBuilder;

  /// Ветка ошибки загрузки списков.
  final Widget Function(
    BuildContext context,
    Exception? exception,
    List<TaskListEntity>? cached,
  )
  listsFailureBuilder;

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      appBar: DefaultAppBar(
        title: Text(
          wm.isEditingTask
              ? CreateTasksStrings.editScreenTitle(context)
              : CreateTasksStrings.screenTitle(context),
        ),
        onBackButtonTap: wm.onCancel,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          CreateTaskActionPanel(wm: wm),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSizes.edgeInsetsAll16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  AppTextField(
                    controller: wm.titleController,
                    decoration: InputDecoration(
                      hintText: CreateTasksStrings.fieldTitleHint(context),
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const Height(AppSizes.double16),

                  AppTextField(
                    controller: wm.descriptionController,
                    decoration: InputDecoration(
                      hintText: CreateTasksStrings.fieldDescriptionHint(
                        context,
                      ),
                    ),
                    minLines: 1,
                    maxLines: 6,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const Height(AppSizes.double16),

                  if (wm.shouldShowOwner) ...<Widget>[
                    _TaskOwnerNotice(ownerLabel: wm.ownerLabel),
                    const Height(AppSizes.double16),
                  ],

                  /// Блок срока и времени задачи
                  TaskDueDateSection(wm: wm),

                  const Height(AppSizes.double16),

                  /// Выбор списка
                  TaskListPicker(
                    wm: wm,
                    listsLoadingBuilder: listsLoadingBuilder,
                    listsFailureBuilder: listsFailureBuilder,
                  ),

                  const Height(AppSizes.double16),

                  /// Блок настройки уведомления
                  TaskReminderSection(wm: wm),

                  const Height(AppSizes.double16),

                  /// Блок настройки постоянных уведомлений
                  TaskRecurringReminderSection(wm: wm),
                  const Height(AppSizes.double16),

                  /// Важность и сложность
                  TaskImportanceComplexitySection(wm: wm),

                  const Height(AppSizes.double16),

                  /// Тэги
                  TaskTagsField(wm: wm),

                  const Height(AppSizes.double16),

                  /// Сумма необходимая для выполнения задачи
                  TaskEstimatedCostField(wm: wm),

                  const Height(AppSizes.double16),

                  /// Добавление материалов
                  MaterialRequirementsBlock(wm: wm),

                  const Height(AppSizes.double16),

                  /// Добавление изображений
                  TaskAttachmentSection(wm: wm),

                  /// Подзадачи
                  if (wm.isEditingTask) ...[
                    const Height(AppSizes.double16),

                    TaskSubtasksSection(wm: wm),
                  ],

                  const Height(AppSizes.double16),

                  /// Выбор родительской задачи
                  ParentTaskPicker(wm: wm),

                  if (wm.isEditingTask)
                    SizedBox(
                      width: double.infinity,
                      child: AppPrimaryButton(
                        onPressed: wm.onOpenChangeHistory,
                        child: Text(
                          CreateTasksStrings.viewChangeHistory(context),
                        ),
                      ),
                    ),
                  const Height(AppSizes.double88),
                ],
              ),
            ),
          ),

          if (!wm.isEditingTask)
            Padding(
              padding: AppSizes.edgeInsetsAll16,
              child: ListenableBuilder(
                listenable: wm.taskSaveState,
                builder: (context, _) {
                  final loading = wm.taskSaveState.value.isLoading;
                  return FilledButton(
                    onPressed: loading ? null : wm.onSave,
                    child: loading
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(
                                width: AppSizes.double20,
                                height: AppSizes.double20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                              const Width(AppSizes.double8),
                              Text(CreateTasksStrings.saving(context)),
                            ],
                          )
                        : Text(CreateTasksStrings.save(context)),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class _TaskOwnerNotice extends StatelessWidget {
  const _TaskOwnerNotice({required this.ownerLabel});

  final String ownerLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.gray100,
        borderRadius: AppSizes.borderRadius12,
        border: Border.all(color: colorScheme.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.double12),
        child: Text(
          CreateTasksStrings.ownerLine(context, owner: ownerLabel),
          style: textScheme.body.t14.copyWith(color: colorScheme.gray700),
        ),
      ),
    );
  }
}

/// Блок строк материалов: название, количество, стоимость, добавление и удаление.
/// Строка выбора дней недели для постоянного напоминания.
