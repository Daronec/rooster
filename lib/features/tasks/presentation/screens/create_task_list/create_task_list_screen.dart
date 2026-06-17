import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_model.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/widgets/desktop/create_task_list_desktop_content.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/widgets/mobile/create_task_list_mobile_content.dart';
import 'package:uuid/uuid.dart';

/// Экран создания списка задач: название и цвет.
@RoutePage(name: 'CreateTaskListRoute')
class CreateTaskListScreen extends BaseWidget<CreateTaskListScreenWidgetModel> {
  /// Создаёт экран.
  const CreateTaskListScreen({super.key, this.listId})
    : super(createTaskListScreenWidgetModelFactory);

  /// Id списка для режима редактирования.
  final String? listId;

  @override
  Widget buildDesktop(CreateTaskListScreenWidgetModel wm) =>
      CreateTaskListDesktopContent(wm: wm);

  @override
  Widget buildMobile(CreateTaskListScreenWidgetModel wm) =>
      CreateTaskListMobileContent(wm: wm);
}

/// Фабрика [CreateTaskListScreenWidgetModel].
CreateTaskListScreenWidgetModel createTaskListScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  final routeArgs = context.routeData.argsAs<CreateTaskListRouteArgs>(
    orElse: () => const CreateTaskListRouteArgs(),
  );
  return CreateTaskListScreenWidgetModel(
    CreateTaskListScreenModel(
      repository: scope.taskListsRepository,
      editingListId: routeArgs.listId,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
    uuid: const Uuid(),
  );
}
