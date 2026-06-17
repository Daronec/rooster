import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_model.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_wm.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/desktop/planning_screen_desktop.dart';
import 'package:rooster/features/planning/presentation/screens/planning/widgets/mobile/planning_screen_mobile.dart';

/// Экран планирования.
@RoutePage(name: 'PlanningRoute')
class PlanningScreen extends BaseWidget<PlanningScreenWidgetModel> {
  /// Создаёт экран.
  const PlanningScreen({super.key}) : super(planningScreenWidgetModelFactory);

  @override
  Widget buildDesktop(PlanningScreenWidgetModel wm) =>
      PlanningScreenDesktop(wm: wm);

  @override
  Widget buildMobile(PlanningScreenWidgetModel wm) =>
      PlanningScreenMobile(wm: wm);
}

/// Фабрика [PlanningScreenWidgetModel].
PlanningScreenWidgetModel planningScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return PlanningScreenWidgetModel(
    PlanningScreenModel(
      planningRepository: scope.planningRepository,
      tasksRepository: scope.tasksRepository,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
