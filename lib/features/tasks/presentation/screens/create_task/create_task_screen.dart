import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_form_state.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_model.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/desktop/create_task_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/mobile/create_task_screen_mobile.dart';
import 'package:rooster/features/tasks/presentation/sounds/task_completion_sound_player.dart';
import 'package:uuid/uuid.dart';

/// Экран создания и редактирования задачи: форма, пикеры даты/времени, списки и сохранение.
@RoutePage(name: 'CreateTaskRoute')
class CreateTaskScreen extends BaseWidget<CreateTaskScreenWidgetModel> {
  /// Создаёт экран.
  const CreateTaskScreen({
    super.key,
    this.taskId,
    this.parentTaskId,
    this.initialTitle,
    this.initialDescription,
    this.initialDependencyTaskIds = const [],
    this.initialDependentTaskIds = const [],
  }) : super(createTaskScreenWidgetModelFactory);

  /// Id задачи для открытия в режиме редактирования.
  final String? taskId;

  /// Id родительской задачи при создании подзадачи.
  final String? parentTaskId;

  /// Начальный заголовок для режима создания.
  final String? initialTitle;

  /// Начальное описание для режима создания.
  final String? initialDescription;

  /// Начальные зависимости для режима создания.
  final List<String> initialDependencyTaskIds;

  /// Задачи, которые должны зависеть от создаваемой задачи после сохранения.
  final List<String> initialDependentTaskIds;

  @override
  Widget buildDesktop(CreateTaskScreenWidgetModel wm) =>
      CreateTaskScreenDesktop(wm: wm);

  @override
  Widget buildMobile(CreateTaskScreenWidgetModel wm) =>
      CreateTaskScreenMobile(wm: wm);
}

/// Фабрика [CreateTaskScreenWidgetModel].
CreateTaskScreenWidgetModel createTaskScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  final routeArgs = context.routeData.argsAs<CreateTaskRouteArgs>(
    orElse: () => const CreateTaskRouteArgs(),
  );
  if (kDebugMode) {
    debugPrint(
      'create_task_route_args taskId=${routeArgs.taskId} parentTaskId=${routeArgs.parentTaskId}',
    );
  }
  final formState = CreateTaskFormState();
  formState.setParentTaskId(routeArgs.parentTaskId);
  formState.setDependencyTaskIds(routeArgs.initialDependencyTaskIds);
  return CreateTaskScreenWidgetModel(
    CreateTaskScreenModel(
      tasksRepository: scope.tasksRepository,
      taskListsRepository: scope.taskListsRepository,
      materialStockRepository: scope.materialStockRepository,
      completeTaskAndConsumeStockMaterialsUseCase:
          scope.completeTaskAndConsumeStockMaterialsUseCase,
      taskLocalImageGateway: scope.taskLocalImageGateway,
      authGateway: scope.authGateway,
      authBackendStrategy: scope.authBackendStrategy,
      teamsGateway: scope.teamsGateway,
      uuid: const Uuid(),
      editingTaskId: routeArgs.taskId,
      initialTitle: routeArgs.initialTitle,
      initialDescription: routeArgs.initialDescription,
      initialDependentTaskIds: routeArgs.initialDependentTaskIds,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
    formState: formState,
    taskCompletionSoundPlayer: TaskCompletionSoundPlayer(
      logger: scope.logger,
    ),
  );
}
