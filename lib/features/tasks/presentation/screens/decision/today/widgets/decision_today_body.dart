import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_view_data.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';
import 'package:union_state/union_state.dart';

/// Тело экрана «Сегодня»: [UnionStateListenableBuilder] + список карточек.
class DecisionTodayBody extends StatelessWidget {
  /// Создаёт виджет.
  const DecisionTodayBody({
    required this.bodyState,
    required this.showMore,
    required this.openTask,
    required this.retry,
    super.key,
  });

  /// Состояние.
  final UnionStateListenable<DecisionTodayViewData> bodyState;

  /// Показать ещё.
  final VoidCallback showMore;

  /// Открыть задачу.
  final void Function(TaskEntity task) openTask;

  /// Повтор после ошибки.
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return UnionStateListenableBuilder<DecisionTodayViewData>(
      unionStateListenable: bodyState,
      loadingBuilder: (context, last) => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.double24),
          child: CircularProgressIndicator(),
        ),
      ),
      failureBuilder: (context, exception, last) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exception?.toString() ??
                    TasksDecisionStrings.todayLoadError(context),
                style: AppTextStyle.t14.value.copyWith(color: colorScheme.red),
                textAlign: TextAlign.center,
              ),
              const Height(AppSizes.double16),
              FilledButton(
                onPressed: retry,
                child: Text(TasksDecisionStrings.todayRetry(context)),
              ),
            ],
          ),
        );
      },
      builder: (context, data) {
        if (data.totalReadyCount == 0) {
          return Center(
            child: Text(
              TasksDecisionStrings.todayEmpty(context),
              style: AppTextStyle.t16.value.copyWith(color: colorScheme.gray700),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              TasksDecisionStrings.todaySummary(
                context,
                count: data.totalReadyCount,
              ),
              style: AppTextStyle.t16Medium.value.copyWith(color: colorScheme.gray900),
            ),
            const Height( AppSizes.double12),
            Expanded(
              child: ListView.separated(
                itemCount: data.visibleEntries.length,
                separatorBuilder: (_, __) => const Height( AppSizes.double8),
                itemBuilder: (context, index) {
                  final entry = data.visibleEntries[index];
                  return _TodayTaskCard(
                    entry: entry,
                    onTap: () => openTask(entry.task),
                  );
                },
              ),
            ),
            if (data.canShowMore) ...[
              const Height(AppSizes.double12),
              OutlinedButton(
                onPressed: showMore,
                child: Text(TasksDecisionStrings.todayShowMore(context)),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TodayTaskCard extends StatelessWidget {
  const _TodayTaskCard({
    required this.entry,
    required this.onTap,
  });

  final TaskFeasibilityListEntryEntity entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final task = entry.task;
    final dueLabel = task.dueAt == null
        ? TasksDecisionStrings.todayDueNone(context)
        : MaterialLocalizations.of(context).formatShortDate(task.dueAt!.toLocal());
    return Semantics(
      button: true,
      label: '${task.title}. $dueLabel',
      child: Card(
        color: colorScheme.white,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppSizes.borderRadius8,
          child: Padding(
            padding: AppSizes.edgeInsetsAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: AppTextStyle.t16Medium.value.copyWith(color: colorScheme.gray900),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const Height(AppSizes.double8),
                Text(
                  dueLabel,
                  style: AppTextStyle.t12.value.copyWith(color: colorScheme.gray700),
                ),
                if (task.estimatedCost > 0) ...[
                  const Height(AppSizes.double4),
                  Text(
                    TasksDecisionStrings.todayCostLabel(
                      context,
                      cost: task.estimatedCost,
                    ),
                    style: AppTextStyle.t12.value.copyWith(color: colorScheme.gray700),
                  ),
                ],
                const Height(AppSizes.double4),
                Text(
                  TasksDecisionStrings.todayScoreLabel(
                    context,
                    score: entry.feasibility.score,
                  ),
                  style: AppTextStyle.t12.value.copyWith(color: colorScheme.gray600),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
