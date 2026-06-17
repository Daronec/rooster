import 'package:auto_route/auto_route.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/domain/decision/decision_blocked_section_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_missing_material_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/decision_task_navigation.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/decision_blocked_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/blocked/decision_blocked_screen.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/util/app_typedefs.dart';

/// WM экрана «Заблокировано».
final class DecisionBlockedScreenWidgetModel
    extends BaseWidgetModel<DecisionBlockedScreen, DecisionBlockedScreenModel> {
  /// Создаёт WM.
  DecisionBlockedScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(handledFailureLogWriter: logWriter);

  /// Состояние списка секций «заблокировано».
  UnionStateListenable<List<DecisionBlockedSectionEntity>> get bodyState =>
      model.bodyState;

  /// Открыть карточку задачи.
  Future<void> onOpenTask(TaskEntity task) async {
    await DecisionTaskNavigation.openTaskDetail(context, taskId: task.id);
  }

  /// Создать задачу на покупку недостающего материала.
  Future<void> onCreateMaterialPurchaseTask({
    required TaskEntity sourceTask,
    required TaskMissingMaterialEntity material,
  }) async {
    final title = TasksDecisionStrings.purchaseMaterialTaskTitle(
      context,
      material: material.label,
      quantity: material.missingQuantity,
    );
    final description = TasksDecisionStrings.purchaseMaterialTaskDescription(
      context,
      material: material.label,
      tasks: '- ${sourceTask.title}',
    );
    await context.router.push<void>(
      CreateTaskRoute(
        initialTitle: title,
        initialDescription: description,
        initialDependentTaskIds: [sourceTask.id],
      ),
    );
  }

  /// Повторить подписку после ошибки.
  void onRetryStream() => model.retryStream();
}
