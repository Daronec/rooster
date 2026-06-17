import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/planning/domain/entities/planning_task_entity.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/create_plan_task_model.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan_task/create_plan_task_screen.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/task_ids.dart';
import 'package:rooster/util/extensions/value_notifier_x.dart';
import 'package:union_state/union_state.dart';
import 'package:uuid/uuid.dart';

/// Интерфейс WM экрана создания задачи плана.
abstract interface class ICreatePlanTaskWM implements IBaseWidgetModel {
  /// Контроллер поля названия задачи.
  TextEditingController get titleController;

  /// Текущее значение важности (1–5).
  ValueListenable<double> get importanceListenable;

  /// Состояние сохранения (loading / content / failure).
  ValueListenable<UnionState<void>> get saveState;

  /// Изменить значение важности.
  void onImportanceChanged(double value);

  /// Сохранить задачу и закрыть экран.
  Future<void> onSave();

  /// Закрыть экран без сохранения.
  Future<void> onCancel();
}

/// WM экрана создания задачи плана.
final class CreatePlanTaskWM
    extends BaseWidgetModel<CreatePlanTaskScreen, CreatePlanTaskModel>
    implements ICreatePlanTaskWM {
  /// Создаёт WM.
  CreatePlanTaskWM(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required Uuid uuid,
  }) : _uuid = uuid,
       super(handledFailureLogWriter: logWriter);

  final Uuid _uuid;

  @override
  final TextEditingController titleController = TextEditingController();

  final ValueNotifier<double> _importance = ValueNotifier<double>(3);

  final ValueNotifier<UnionState<void>> _saveState =
      ValueNotifier<UnionState<void>>(const UnionStateContent(null));

  @override
  ValueListenable<double> get importanceListenable => _importance;

  @override
  ValueListenable<UnionState<void>> get saveState => _saveState;

  @override
  void dispose() {
    titleController.dispose();
    _importance.dispose();
    _saveState.dispose();
    super.dispose();
  }

  @override
  void onImportanceChanged(double value) {
    _importance.value = value;
  }

  @override
  Future<void> onSave() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      snackController.addSnack(
        PlanningStrings.validationTaskTitle(context),
        messageType: SnackMessageType.warning,
      );
      return;
    }

    _saveState.emit(const UnionStateLoading());

    try {
      final plan = await model.loadPlan();
      if (!context.mounted) {
        return;
      }
      if (plan == null) {
        _saveState.emit(
          UnionStateFailure(Exception('plan_not_found')),
        );
        snackController.addSnack(
          PlanningStrings.planNotFound(context),
          messageType: SnackMessageType.error,
        );
        return;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      final task = PlanningTaskEntity(
        id: _uuid.v4(),
        title: title,
        order: plan.tasks.length,
        importance: _importance.value.round(),
        isCompleted: false,
        createdAtMillis: now,
        updatedAtMillis: now,
      );

      await model.savePlan(
        plan.copyWith(
          tasks: <PlanningTaskEntity>[...plan.orderedTasks, task],
          updatedAtMillis: now,
        ),
      );
      await model.saveTask(
        TaskEntity(
          id: task.id,
          listId: TaskIds.inboxListId,
          title: task.title,
          importance: task.importance,
          updatedAtMillis: task.updatedAtMillis,
        ),
      );

      if (!context.mounted) {
        return;
      }
      _saveState.emit(const UnionStateContent(null));
      await context.router.maybePop();
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('CreatePlanTaskWM.onSave error: $error');
      }
      _saveState.emit(
        UnionStateFailure(error is Exception ? error : Exception('$error')),
      );
      onErrorHandle(error);
    }
  }

  @override
  Future<void> onCancel() async {
    await context.router.maybePop();
  }
}
