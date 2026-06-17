import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/decision_blocked_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/decision_blocked_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/widgets/desktop/decision_blocked_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/widgets/mobile/decision_blocked_screen_mobile.dart';

/// Экран «Заблокировано»: причины, почему задачи недоступны.
@RoutePage(name: 'DecisionBlockedRoute')
class DecisionBlockedScreen extends BaseWidget<DecisionBlockedScreenWidgetModel> {
  /// Создаёт экран.
  const DecisionBlockedScreen({super.key})
      : super(decisionBlockedScreenWidgetModelFactory);

  @override
  Widget buildDesktop(DecisionBlockedScreenWidgetModel wm) =>
      DecisionBlockedScreenDesktop(wm: wm);

  @override
  Widget buildMobile(DecisionBlockedScreenWidgetModel wm) =>
      DecisionBlockedScreenMobile(wm: wm);
}

/// Фабрика [DecisionBlockedScreenWidgetModel] для [DecisionBlockedScreen].
DecisionBlockedScreenWidgetModel decisionBlockedScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return DecisionBlockedScreenWidgetModel(
    DecisionBlockedScreenModel(
      tasksRepository: scope.tasksRepository,
      budgetRepository: scope.budgetRepository,
      listBlockedTasksWithReasonsUseCase: scope.listBlockedTasksWithReasonsUseCase,
      logWriter: scope.logger,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
