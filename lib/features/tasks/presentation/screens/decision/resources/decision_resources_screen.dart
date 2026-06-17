import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/widgets/desktop/decision_resources_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/widgets/mobile/decision_resources_screen_mobile.dart';

/// Экран «Ресурсы»: бюджет периода и склад материалов.
@RoutePage(name: 'DecisionResourcesRoute')
class DecisionResourcesScreen
    extends BaseWidget<DecisionResourcesScreenWidgetModel> {
  /// Создаёт экран.
  const DecisionResourcesScreen({super.key})
    : super(decisionResourcesScreenWidgetModelFactory);

  @override
  Widget buildDesktop(DecisionResourcesScreenWidgetModel wm) =>
      DecisionResourcesScreenDesktop(wm: wm);

  @override
  Widget buildMobile(DecisionResourcesScreenWidgetModel wm) =>
      DecisionResourcesScreenMobile(wm: wm);
}

/// Фабрика [DecisionResourcesScreenWidgetModel].
DecisionResourcesScreenWidgetModel decisionResourcesScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return DecisionResourcesScreenWidgetModel(
    DecisionResourcesScreenModel(
      budgetRepository: scope.budgetRepository,
      materialStockRepository: scope.materialStockRepository,
      tasksRepository: scope.tasksRepository,
      logWriter: scope.logger,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
