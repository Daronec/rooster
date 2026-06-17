import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_model.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/desktop/task_lists_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/widgets/mobile/task_lists_screen_mobile.dart';

/// Списки задач.
@RoutePage(name: 'TaskListsRoute')
class TaskListsScreen extends BaseWidget<TaskListsScreenWidgetModel> {
  /// Создаёт экран.
  const TaskListsScreen({super.key}) : super(taskListsScreenWidgetModelFactory);

  @override
  Widget buildDesktop(TaskListsScreenWidgetModel wm) =>
      TaskListsScreenDesktop(wm: wm);

  @override
  Widget buildMobile(TaskListsScreenWidgetModel wm) =>
      TaskListsScreenMobile(wm: wm);
}

/// Фабрика [TaskListsScreenWidgetModel].
TaskListsScreenWidgetModel taskListsScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return TaskListsScreenWidgetModel(
    TaskListsScreenModel(repository: scope.taskListsRepository),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
