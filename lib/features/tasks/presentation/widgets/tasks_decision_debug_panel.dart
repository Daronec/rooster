import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Панель превью движка решений (только [kDebugMode], D3-05).
class TasksDecisionDebugPanel extends StatelessWidget {
  /// Создаёт панель.
  const TasksDecisionDebugPanel({required this.widgetModel, super.key});

  /// WM списка задач.
  final TasksScreenWidgetModel widgetModel;

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) {
      return const SizedBox.shrink();
    }
    final colorScheme = AppColorScheme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: AppSizes.double12),
      color: colorScheme.gray100,
      child: ExpansionTile(
        title: Text(
          TasksStrings.decisionDebugPanelTitle(context),
          style: AppTextStyle.t12Medium.value.copyWith(
            color: colorScheme.gray900,
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(AppSizes.double12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  TasksStrings.decisionDebugTodaySection(context),
                  style: AppTextStyle.t12Bold.value.copyWith(
                    color: colorScheme.gray900,
                  ),
                ),
                const Height(AppSizes.double8),
                ValueListenableBuilder<List<TaskFeasibilityListEntryEntity>>(
                  valueListenable: widgetModel.todayReadyPreviewListenable,
                  builder: (context, todayEntries, _) {
                    if (todayEntries.isEmpty) {
                      return Text(
                        TasksStrings.decisionDebugEmptyToday(context),
                        style: AppTextStyle.t12.value.copyWith(
                          color: colorScheme.gray700,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in todayEntries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.double4),
                            child: Text(
                              '${entry.task.title} — '
                              '${TasksStrings.decisionDebugScoreLabel(context, score: entry.feasibility.score)}',
                              style: AppTextStyle.t12.value.copyWith(
                                color: colorScheme.gray900,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
                const Height(AppSizes.double12),
                Text(
                  TasksStrings.decisionDebugBlockedSection(context),
                  style: AppTextStyle.t12Bold.value.copyWith(
                    color: colorScheme.gray900,
                  ),
                ),
                const Height(AppSizes.double8),
                ValueListenableBuilder<List<TaskFeasibilityListEntryEntity>>(
                  valueListenable: widgetModel.blockedPreviewListenable,
                  builder: (context, blockedEntries, _) {
                    if (blockedEntries.isEmpty) {
                      return Text(
                        TasksStrings.decisionDebugEmptyBlocked(context),
                        style: AppTextStyle.t12.value.copyWith(
                          color: colorScheme.gray700,
                        ),
                      );
                    }
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (final entry in blockedEntries)
                          Padding(
                            padding: const EdgeInsets.only(bottom: AppSizes.double4),
                            child: Text(
                              '${entry.task.title} — ${entry.feasibility.status.name}',
                              style: AppTextStyle.t12.value.copyWith(
                                color: colorScheme.gray900,
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
