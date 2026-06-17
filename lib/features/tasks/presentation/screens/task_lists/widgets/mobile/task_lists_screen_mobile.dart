import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/mobile/task_lists_mobile_content.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/mobile/task_lists_mobile_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/mobile/task_lists_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран списков задач (mobile).
class TaskListsScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const TaskListsScreenMobile({required this.wm, super.key});

  /// Widget model экрана.
  final TaskListsScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          TaskListsMobileLoading(wm: wm),
      builder: (context, data) =>
          TaskListsMobileContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return TaskListsMobileFailure(
          wm: wm,
          error: exception ?? Exception('task_lists_stream'),
        );
      },
    );
  }
}
