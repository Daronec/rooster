import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_queue_provider.dart';
import 'package:rooster/core/architecture/presentation/base_widget.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/widgets/desktop/decision_today_screen_desktop.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/widgets/mobile/decision_today_screen_mobile.dart';

/// Экран «Сегодня»: топ готовых задач по score.
@RoutePage(name: 'DecisionTodayRoute')
class DecisionTodayScreen extends BaseWidget<DecisionTodayScreenWidgetModel> {
  /// Создаёт экран.
  const DecisionTodayScreen({super.key}) : super(decisionTodayScreenWidgetModelFactory);

  @override
  Widget buildDesktop(DecisionTodayScreenWidgetModel wm) =>
      DecisionTodayScreenDesktop(wm: wm);

  @override
  Widget buildMobile(DecisionTodayScreenWidgetModel wm) =>
      DecisionTodayScreenMobile(wm: wm);
}

/// Фабрика [DecisionTodayScreenWidgetModel].
DecisionTodayScreenWidgetModel decisionTodayScreenWidgetModelFactory(
  BuildContext context,
) {
  final scope = context.read<IAppScope>();
  return DecisionTodayScreenWidgetModel(
    DecisionTodayScreenModel(
      tasksRepository: scope.tasksRepository,
      budgetRepository: scope.budgetRepository,
      listTodayReadyTasksUseCase: scope.listTodayReadyTasksUseCase,
      logWriter: scope.logger,
    ),
    snackController: SnackQueueProvider.of(context),
    logWriter: scope.logger,
  );
}
