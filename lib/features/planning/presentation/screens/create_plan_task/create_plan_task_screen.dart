import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/create_plan_task_model.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/create_plan_task_wm.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/widgets/desktop/create_plan_task_desktop_content.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/widgets/mobile/create_plan_task_mobile_content.dart';
import 'package:uuid/uuid.dart';

/// Экран создания задачи плана.
@RoutePage(name: 'CreatePlanTaskRoute')
class CreatePlanTaskScreen extends BaseWidget<ICreatePlanTaskWM> {
  /// Создаёт экран.
  const CreatePlanTaskScreen({
    /// ID плана, к которому добавляется задача.
    @PathParam('planId') required this.planId,
    super.key,
  }) : super(createPlanTaskWidgetModelFactory);

  /// ID плана, к которому добавляется задача.
  final String planId;

  @override
  Widget buildMobile(ICreatePlanTaskWM wm) =>
      CreatePlanTaskMobileContent(wm: wm);

  @override
  Widget buildDesktop(ICreatePlanTaskWM wm) =>
      CreatePlanTaskDesktopContent(wm: wm);
}

/// Фабрика [CreatePlanTaskWM].
CreatePlanTaskWM createPlanTaskWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  final routeArgs = context.routeData.argsAs<CreatePlanTaskRouteArgs>();
  return CreatePlanTaskWM(
    CreatePlanTaskModel(
      planningRepository: scope.planningRepository,
      tasksRepository: scope.tasksRepository,
      planId: routeArgs.planId,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
    uuid: const Uuid(),
  );
}
