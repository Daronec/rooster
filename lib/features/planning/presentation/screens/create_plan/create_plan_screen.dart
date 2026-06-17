import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/create_plan_model.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/create_plan_wm.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/widgets/desktop/create_plan_desktop_content.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/widgets/mobile/create_plan_mobile_content.dart';
import 'package:uuid/uuid.dart';

/// Экран создания плана.
@RoutePage(name: 'CreatePlanRoute')
class CreatePlanScreen extends BaseWidget<ICreatePlanWM> {
  /// Создаёт экран.
  const CreatePlanScreen({super.key}) : super(createPlanWidgetModelFactory);

  @override
  Widget buildMobile(ICreatePlanWM wm) => CreatePlanMobileContent(wm: wm);

  @override
  Widget buildDesktop(ICreatePlanWM wm) => CreatePlanDesktopContent(wm: wm);
}

/// Фабрика [CreatePlanWM].
CreatePlanWM createPlanWidgetModelFactory(BuildContext context) {
  final scope = context.read<IAppScope>();
  return CreatePlanWM(
    CreatePlanModel(planningRepository: scope.planningRepository),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
    uuid: const Uuid(),
  );
}
