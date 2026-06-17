import 'package:flutter/material.dart';
import 'package:day_picker/day_picker.dart';
import 'package:rooster/features/tasks/domain/entities/task_weekday_mask_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Строка выбора дней недели для постоянного напоминания.
final class WeekdayChipsRow extends StatelessWidget {
  /// Создаёт строку выбора.
  const WeekdayChipsRow({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return ListenableBuilder(
      listenable: wm.formState,
      builder: (context, _) {
        final mask = wm.formState.recurrenceWeekdaysMask;
        final days = <DayInWeek>[
          DayInWeek(
            CreateTasksStrings.weekdayMon(context),
            dayKey: 'monday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.monday),
          ),
          DayInWeek(
            CreateTasksStrings.weekdayTue(context),
            dayKey: 'tuesday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.tuesday),
          ),
          DayInWeek(
            CreateTasksStrings.weekdayWed(context),
            dayKey: 'wednesday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.wednesday),
          ),
          DayInWeek(
            CreateTasksStrings.weekdayThu(context),
            dayKey: 'thursday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.thursday),
          ),
          DayInWeek(
            CreateTasksStrings.weekdayFri(context),
            dayKey: 'friday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.friday),
          ),
          DayInWeek(
            CreateTasksStrings.weekdaySat(context),
            dayKey: 'saturday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.saturday),
          ),
          DayInWeek(
            CreateTasksStrings.weekdaySun(context),
            dayKey: 'sunday',
            isSelected: TaskWeekdayMaskEntity.hasDay(mask, TaskWeekdayMaskEntity.sunday),
          ),
        ];
        return SelectWeekDays(
          days: days,
          border: false,
          padding: AppSizes.double4,
          selectedDaysFillColor: colorScheme.primaryLight,
          unselectedDaysFillColor: colorScheme.gray100,
          selectedDayTextColor: colorScheme.primaryNormal,
          unSelectedDayTextColor: colorScheme.gray900,
          onSelect: (selectedKeys) {
            wm.formState.setRecurrenceWeekdaysMask(
              _maskFromSelectedKeys(selectedKeys),
            );
          },
        );
      },
    );
  }

  int _maskFromSelectedKeys(List<String> keys) {
    var mask = TaskWeekdayMaskEntity.empty;
    for (final key in keys) {
      mask |= switch (key) {
        'monday' => TaskWeekdayMaskEntity.monday,
        'tuesday' => TaskWeekdayMaskEntity.tuesday,
        'wednesday' => TaskWeekdayMaskEntity.wednesday,
        'thursday' => TaskWeekdayMaskEntity.thursday,
        'friday' => TaskWeekdayMaskEntity.friday,
        'saturday' => TaskWeekdayMaskEntity.saturday,
        'sunday' => TaskWeekdayMaskEntity.sunday,
        _ => TaskWeekdayMaskEntity.empty,
      };
    }
    return mask;
  }
}
