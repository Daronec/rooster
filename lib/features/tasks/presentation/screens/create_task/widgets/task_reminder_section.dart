import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/fields/widgets/common/app_dropdown.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Блок настройки уведомления (пресет + кастомная дата/время).
final class TaskReminderSection extends StatelessWidget {
  /// Создаёт блок.
  const TaskReminderSection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wm.formState,
      builder: (context, _) {
        final customReminderAt = wm.formState.customReminderAt;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            AppDropdown(
              label: CreateTasksStrings.sectionReminder(context),
              emptyMessage: CreateTasksStrings.sectionReminder(context),
              placeholder: CreateTasksStrings.sectionReminder(context),
              valueListenable: wm.formState.reminderPresetListenable,
              options: TaskReminderPresetEntity.values
                  .map(
                    (preset) => AppDropdownEntity(
                      id: preset.name,
                      label: CreateTasksStrings.reminderPreset(
                        context,
                        preset.name,
                      ),
                    ),
                  )
                  .toList(growable: false),
              onChanged: (id) {
                if (id == null) {
                  wm.formState.setReminderPreset(TaskReminderPresetEntity.none);
                  return;
                }
                wm.formState.setReminderPreset(
                  TaskReminderPresetEntity.values.firstWhere(
                    (preset) => preset.name == id,
                  ),
                );
              },
            ),
            if (wm.formState.reminderPreset ==
                TaskReminderPresetEntity.custom) ...<Widget>[
              const Height(AppSizes.double8),
              OutlinedButton.icon(
                onPressed: wm.onPickCustomReminder,
                icon: const Icon(Icons.alarm_add_outlined),
                label: Text(
                  customReminderAt == null
                      ? CreateTasksStrings.pickCustomReminder(context)
                      : CreateTasksStrings.customReminderValue(
                          context,
                          date: _formatCustomReminder(
                            context,
                            customReminderAt,
                          ),
                        ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  String _formatCustomReminder(BuildContext context, DateTime value) {
    final localValue = value.toLocal();
    final localizations = MaterialLocalizations.of(context);
    final date = localizations.formatMediumDate(localValue);
    final time = localizations.formatTimeOfDay(
      TimeOfDay.fromDateTime(localValue),
    );
    return '$date $time';
  }
}
