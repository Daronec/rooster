import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/others/app_property_switch_tile.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Блок срока и времени задачи: дата, режим «весь день», время начала/окончания.
final class TaskDueDateSection extends StatelessWidget {
  /// Создаёт секцию.
  const TaskDueDateSection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wm.formState,
      builder: (context, _) {
        final colorScheme = AppColorScheme.of(context);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: wm.onPickDueDate,
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: AppSizes.double16,
                          color: colorScheme.primaryNormal,
                        ),
                        const Width(AppSizes.double8),
                        Text(
                          _formatDate(context, wm.formState.dueDate),
                          style: AppTextStyle.t14.value.copyWith(
                            color: colorScheme.primaryNormal,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: AppPropertySwitchTile(
                    name: CreateTasksStrings.allDay(context),
                    isActive: wm.formState.isAllDay,
                    onSwitch: wm.formState.setAllDay,
                  ),
                ),
              ],
            ),

            if (!wm.formState.isAllDay)
              Row(
                children: [
                  Expanded(
                    child: AppPrimaryButton(
                      onPressed: wm.onPickStartTime,
                      child: Text(
                        '${CreateTasksStrings.fieldStartTime(context)} ${wm.formState.startTime.format(context)}',
                      ),
                    ),
                  ),
                  const Width(AppSizes.double8),
                  Expanded(
                    child: AppPrimaryButton(
                      onPressed: wm.onPickEndTime,
                      child: Text(
                        '${CreateTasksStrings.fieldEndTime(context)} ${wm.formState.endTime.format(context)}',
                      ),
                    ),
                  ),
                ],
              ),
          ],
        );
      },
    );
  }

  String _formatDate(BuildContext context, DateTime date) {
    return MaterialLocalizations.of(context).formatMediumDate(date);
  }
}
