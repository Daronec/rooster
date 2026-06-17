import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/desktop/task_detail_desktop_content.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/desktop/task_detail_desktop_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/desktop/task_detail_desktop_loading.dart';
import 'package:union_state/union_state.dart';

/// Экран детального просмотра задачи (desktop).
class TaskDetailScreenDesktop extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const TaskDetailScreenDesktop({required this.wm, super.key});

  /// Widget model экрана деталей.
  final TaskDetailScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<TaskEntity>(
      unionStateListenable: wm.detailState,
      loadingBuilder: (context, last) =>
          const TaskDetailDesktopLoading(),
      builder: (context, task) =>
          TaskDetailDesktopContent(wm: wm, task: task),
      failureBuilder:
          (context, exception, last) {
        return TaskDetailDesktopFailure(wm: wm, exception: exception);
      },
    );
  }
}
