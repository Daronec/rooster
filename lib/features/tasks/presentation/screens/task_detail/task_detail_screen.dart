import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_model.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/desktop/task_detail_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/widgets/mobile/task_detail_screen_mobile.dart';
import 'package:rooster/features/tasks/presentation/sounds/task_completion_sound_player.dart';

/// Экран детального просмотра задачи.
@RoutePage(name: 'TaskDetailRoute')
class TaskDetailScreen extends BaseWidget<TaskDetailScreenWidgetModel> {
  /// Создаёт экран.
  const TaskDetailScreen({required this.taskId, super.key})
    : super(taskDetailScreenWidgetModelFactory);

  /// Id задачи для просмотра.
  final String taskId;

  @override
  Widget buildDesktop(TaskDetailScreenWidgetModel wm) =>
      TaskDetailScreenDesktop(wm: wm);

  @override
  Widget buildMobile(TaskDetailScreenWidgetModel wm) =>
      TaskDetailScreenMobile(wm: wm);
}

/// Фабрика [TaskDetailScreenWidgetModel].
TaskDetailScreenWidgetModel taskDetailScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  final routeArgs = context.routeData.argsAs<TaskDetailRouteArgs>();
  return TaskDetailScreenWidgetModel(
    TaskDetailScreenModel(
      taskId: routeArgs.taskId,
      tasksRepository: scope.tasksRepository,
      taskListsRepository: scope.taskListsRepository,
      completeTaskAndConsumeStockMaterialsUseCase:
          scope.completeTaskAndConsumeStockMaterialsUseCase,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
    taskCompletionSoundPlayer: TaskCompletionSoundPlayer(
      logger: scope.logger,
    ),
  );
}
