import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/desktop/tasks_desktop_content.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/desktop/tasks_desktop_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/desktop/tasks_desktop_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран списка задач (desktop).
class TasksScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const TasksScreenDesktop({required this.wm, super.key});

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          TasksDesktopLoading(wm: wm),
      builder: (context, data) =>
          TasksDesktopContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return TasksDesktopFailure(
          wm: wm,
          error: exception ?? Exception('tasks_stream'),
        );
      },
    );
  }
}
