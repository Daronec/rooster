import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/weekday_chips_row.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Блок настройки постоянных уведомлений: дни недели и время.
final class TaskRecurringReminderSection extends StatelessWidget {
  /// Создаёт блок.
  const TaskRecurringReminderSection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          CreateTasksStrings.sectionRecurring(context),
          style: AppTextStyle.t14Medium.value,
        ),
        const Height(AppSizes.double8),
        WeekdayChipsRow(wm: wm),
        AppPrimaryButton(
          onPressed: wm.onPickRecurrenceTime,
          child: Text(
            '${CreateTasksStrings.pickTime(context)} ${wm.formState.recurrenceTime.format(context)}',
          ),
        ),

      ],
    );
  }
}

