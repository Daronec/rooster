import 'package:flutter/material.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/entities/planning_task_entity.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Карточка плана со списком задач.
class PlanningPlanCard extends StatelessWidget {
  /// Создаёт карточку.
  const PlanningPlanCard({
    required this.plan,
    required this.wm,
    super.key,
  });

  /// Отображаемый план.
  final PlanningPlanEntity plan;

  /// Widget model экрана планирования.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    final totalTasks = plan.totalTasks;
    final progress = totalTasks == 0 ? 0.0 : plan.completedTasks / totalTasks;

    return Card(
      color: colorScheme.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.double12,
          vertical: AppSizes.double10,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            // Заголовок и кнопка удаления.
            _PlanCardHeader(plan: plan, wm: wm),
            const Height(AppSizes.double4),
            // Описание цели.
            Text(
              plan.goalDescription,
              style: textScheme.body.t14.copyWith(color: colorScheme.gray700),
            ),
            const Height(AppSizes.double4),
            // Период.
            Text(
              '${PlanningStrings.periodLabel(context)}: ${wm.formatPeriod(plan)}',
              style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
            ),
            const Height(AppSizes.double8),
            // Прогресс-бар.
            LinearProgressIndicator(value: progress),
            const Height(AppSizes.double4),
            // Счётчики задач.
            Text(
              '${PlanningStrings.remainingTasks(context, plan.remainingTasks)} · '
              '${PlanningStrings.completedOf(context, plan.completedTasks, totalTasks)}',
              style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
            ),
            const Height(AppSizes.double8),
            // Кнопка добавления задачи — над списком задач.
            _AddTaskButton(plan: plan, wm: wm),
            // Список задач (если есть).
            if (plan.tasks.isNotEmpty) ...<Widget>[
              const Height(AppSizes.double4),
              ...plan.orderedTasks.map(
                (task) => PlanningTaskTile(plan: plan, task: task, wm: wm),
              ),
            ] else ...<Widget>[
              const Height(AppSizes.double4),
              Text(
                PlanningStrings.noTasks(context),
                style: textScheme.body.t14.copyWith(color: colorScheme.gray600),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Заголовок карточки плана с кнопкой удаления.
class _PlanCardHeader extends StatelessWidget {
  const _PlanCardHeader({required this.plan, required this.wm});

  /// Отображаемый план.
  final PlanningPlanEntity plan;

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return Row(
      children: <Widget>[
        Expanded(
          child: Text(
            plan.title,
            style: textScheme.body.t16.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.gray900,
            ),
          ),
        ),
        IconButton(
          tooltip: PlanningStrings.delete(context),
          onPressed: () => wm.onDeletePlan(plan),
          icon: Icon(Icons.delete_outline, color: colorScheme.gray600),
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
        ),
      ],
    );
  }
}

/// Кнопка добавления задачи в план.
class _AddTaskButton extends StatelessWidget {
  const _AddTaskButton({required this.plan, required this.wm});

  /// Отображаемый план.
  final PlanningPlanEntity plan;

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: TextButton.icon(
        onPressed: () => wm.onAddTask(plan),
        icon: const Icon(Icons.add, size: AppSizes.double16),
        label: Text(PlanningStrings.createTask(context)),
        style: TextButton.styleFrom(
          visualDensity: VisualDensity.compact,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSizes.double8,
            vertical: AppSizes.double4,
          ),
        ),
      ),
    );
  }
}

/// Строка задачи плана.
class PlanningTaskTile extends StatelessWidget {
  /// Создаёт строку задачи.
  const PlanningTaskTile({
    required this.plan,
    required this.task,
    required this.wm,
    super.key,
  });

  /// Отображаемый план.
  final PlanningPlanEntity plan;

  /// Задача плана.
  final PlanningTaskEntity task;

  /// Widget model экрана.
  final PlanningScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    final orderedTasks = plan.orderedTasks;
    final taskIndex = orderedTasks.indexWhere((item) => item.id == task.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSizes.double4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: colorScheme.gray100,
          borderRadius: AppSizes.borderRadius8,
        ),
        child: ListTile(
          onTap: () => wm.onOpenTask(task),
          dense: true,
          visualDensity: VisualDensity.compact,
          contentPadding: const EdgeInsets.only(left: AppSizes.double4),
          leading: Checkbox(
            value: task.isCompleted,
            visualDensity: VisualDensity.compact,
            onChanged: (isCompleted) => wm.onToggleTaskCompleted(
              plan,
              task,
              completed: isCompleted ?? false,
            ),
          ),
          title: Text(
            task.title,
            style: textScheme.body.t14.copyWith(
              decoration: task.isCompleted ? TextDecoration.lineThrough : null,
              color: task.isCompleted
                  ? colorScheme.gray600
                  : colorScheme.gray900,
            ),
          ),
          subtitle: Text(
            '${PlanningStrings.importanceLabel(context)}: ${task.importance}',
            style: textScheme.body.t12.copyWith(color: colorScheme.gray600),
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              IconButton(
                onPressed: taskIndex <= 0
                    ? null
                    : () => wm.onMoveTaskUp(plan, task.id),
                icon: const Icon(Icons.keyboard_arrow_up),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
              IconButton(
                onPressed: taskIndex >= orderedTasks.length - 1
                    ? null
                    : () => wm.onMoveTaskDown(plan, task.id),
                icon: const Icon(Icons.keyboard_arrow_down),
                visualDensity: VisualDensity.compact,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
