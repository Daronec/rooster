import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/mobile/task_change_history_mobile_content.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/mobile/task_change_history_mobile_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/mobile/task_change_history_mobile_loading.dart';
import 'package:rooster/util/union_state/union_state_list_body.dart';

/// Экран истории изменений (mobile).
class TaskChangeHistoryScreenMobile extends StatelessWidget {
  /// Создаёт виджет.
  const TaskChangeHistoryScreenMobile({required this.wm, super.key});

  /// Widget model экрана.
  final TaskChangeHistoryScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListBody(
      unionStateListenable: wm.changesState,
      loadingBuilder: (context, cached) =>
          const TaskChangeHistoryMobileLoading(),
      failureBuilder: (context, exception, cached) =>
          TaskChangeHistoryMobileFailure(onRetry: wm.onRetry),
      builder: (context, changes) =>
          TaskChangeHistoryMobileContent(wm: wm, changes: changes),
    );
  }
}




