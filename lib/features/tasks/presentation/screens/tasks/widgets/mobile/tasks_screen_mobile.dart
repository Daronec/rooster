import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/mobile/tasks_mobile_content.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/mobile/tasks_mobile_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/mobile/tasks_mobile_loading.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Экран списка задач (mobile).
class TasksScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const TasksScreenMobile({required this.wm, super.key});

  /// Widget model экрана задач.
  final TasksScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<EmptyScreenBody>(
      unionStateListenable: wm.bodyState,
      loadingBuilder: (context, last) =>
          TasksMobileLoading(wm: wm),
      builder: (context, data) =>
          TasksMobileContent(wm: wm),
      failureBuilder:
          (context, exception, last) {
        return TasksMobileFailure(
          wm: wm,
          error: exception ?? Exception('tasks_stream'),
        );
      },
    );
  }
}
