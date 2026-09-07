import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_model.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/desktop/task_change_history_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/widgets/mobile/task_change_history_screen_mobile.dart';

/// Экран истории изменений задачи.
@RoutePage(name: 'TaskChangeHistoryRoute')
class TaskChangeHistoryScreen
    extends BaseWidget<TaskChangeHistoryScreenWidgetModel> {
  /// Создаёт экран.
  const TaskChangeHistoryScreen({required this.taskId, super.key})
    : super(taskChangeHistoryScreenWidgetModelFactory);

  /// Id задачи.
  final String taskId;

  @override
  Widget buildDesktop(TaskChangeHistoryScreenWidgetModel wm) =>
      TaskChangeHistoryScreenDesktop(wm: wm);

  @override
  Widget buildMobile(TaskChangeHistoryScreenWidgetModel wm) =>
      TaskChangeHistoryScreenMobile(wm: wm);
}

/// Фабрика [TaskChangeHistoryScreenWidgetModel].
TaskChangeHistoryScreenWidgetModel taskChangeHistoryScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  final routeArgs = context.routeData.argsAs<TaskChangeHistoryRouteArgs>();
  return TaskChangeHistoryScreenWidgetModel(
    TaskChangeHistoryScreenModel(
      taskId: routeArgs.taskId,
      taskChangeHistoryRepository: scope.taskChangeHistoryRepository,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
