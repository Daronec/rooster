import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/desktop/task_lists_desktop_content.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/desktop/task_lists_desktop_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/desktop/task_lists_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран списков задач (desktop).
class TaskListsScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const TaskListsScreenDesktop({required this.wm, super.key});

  /// Widget model экрана.
  final TaskListsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          TaskListsDesktopLoading(wm: wm),
      builder: (context, data) =>
          TaskListsDesktopContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return TaskListsDesktopFailure(
          wm: wm,
          error: exception ?? Exception('task_lists_stream'),
        );
      },
    );
  }
}
