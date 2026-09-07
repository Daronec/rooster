import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/desktop/task_change_history_desktop_content.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/desktop/task_change_history_desktop_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/desktop/task_change_history_desktop_loading.dart';
import 'package:rooster/util/union_state/union_state_list_body.dart';

/// Экран истории изменений (desktop).
class TaskChangeHistoryScreenDesktop extends StatelessWidget {
  /// Создаёт виджет.
  const TaskChangeHistoryScreenDesktop({required this.wm, super.key});

  /// Widget model экрана.
  final TaskChangeHistoryScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListBody(
      unionStateListenable: wm.changesState,
      loadingBuilder: (context, cached) =>
          const TaskChangeHistoryDesktopLoading(),
      failureBuilder: (context, exception, cached) =>
          TaskChangeHistoryDesktopFailure(onRetry: wm.onRetry),
      builder: (context, changes) =>
          TaskChangeHistoryDesktopContent(wm: wm, changes: changes),
    );
  }
}


