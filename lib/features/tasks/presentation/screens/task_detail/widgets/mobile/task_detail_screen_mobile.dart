import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/mobile/task_detail_mobile_content.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/mobile/task_detail_mobile_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/mobile/task_detail_mobile_loading.dart';
import 'package:union_state/union_state.dart';

/// Экран детального просмотра задачи (mobile).
class TaskDetailScreenMobile extends StatelessWidget {
  /// Создаёт оболочку экрана.
  const TaskDetailScreenMobile({required this.wm, super.key});

  /// Widget model экрана деталей.
  final TaskDetailScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return UnionStateListenableBuilder<TaskEntity>(
      unionStateListenable: wm.detailState,
      loadingBuilder: (context, last) =>
          const TaskDetailMobileLoading(),
      builder: (context, task) =>
          TaskDetailMobileContent(wm: wm, task: task),
      failureBuilder:
          (context, exception, last) {
        return TaskDetailMobileFailure(wm: wm, exception: exception);
      },
    );
  }
}
