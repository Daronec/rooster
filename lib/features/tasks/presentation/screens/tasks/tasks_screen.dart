import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_model.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/desktop/tasks_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/widgets/mobile/tasks_screen_mobile.dart';
import 'package:rooster/features/tasks/presentation/sounds/task_completion_sound_player.dart';

/// Список задач.
@RoutePage(name: 'TasksRoute')
class TasksScreen extends BaseWidget<TasksScreenWidgetModel> {
  /// Создаёт экран.
  const TasksScreen({super.key}) : super(tasksScreenWidgetModelFactory);

  @override
  Widget buildDesktop(TasksScreenWidgetModel wm) => TasksScreenDesktop(wm: wm);

  @override
  Widget buildMobile(TasksScreenWidgetModel wm) => TasksScreenMobile(wm: wm);
}

/// Фабрика [TasksScreenWidgetModel].
TasksScreenWidgetModel tasksScreenWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  return TasksScreenWidgetModel(
    TasksScreenModel(
      tasksRepository: scope.tasksRepository,
      taskListsRepository: scope.taskListsRepository,
      expandedGroupStorage: scope.tasksScreenExpandedGroupStorage,
      listTodayReadyTasksUseCase: scope.listTodayReadyTasksUseCase,
      listBlockedTasksWithReasonsUseCase:
          scope.listBlockedTasksWithReasonsUseCase,
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
