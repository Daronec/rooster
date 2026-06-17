import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/entities/planning_task_entity.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/create_plan_model.dart';
import 'package:rooster/features/planning/presentation/screens/create_plan/create_plan_screen.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/util/extensions/value_notifier_x.dart';
import 'package:union_state/union_state.dart';
import 'package:uuid/uuid.dart';

/// Интерфейс WM экрана создания плана.
abstract interface class ICreatePlanWM implements IBaseWidgetModel {
  /// Контроллер поля названия плана.
  TextEditingController get titleController;

  /// Контроллер поля цели плана.
  TextEditingController get goalController;

  /// Выбранная дата начала периода.
  ValueListenable<DateTime> get periodStartListenable;

  /// Выбранная дата окончания периода.
  ValueListenable<DateTime> get periodEndListenable;

  /// Состояние сохранения (loading / content / failure).
  ValueListenable<UnionState<void>> get saveState;

  /// Выбрать дату начала периода.
  Future<void> onPickStartDate();

  /// Выбрать дату окончания периода.
  Future<void> onPickEndDate();

  /// Сохранить план и закрыть экран.
  Future<void> onSave();

  /// Закрыть экран без сохранения.
  Future<void> onCancel();
}

/// WM экрана создания плана.
final class CreatePlanWM
    extends BaseWidgetModel<CreatePlanScreen, CreatePlanModel>
    implements ICreatePlanWM {
  /// Создаёт WM.
  CreatePlanWM(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required Uuid uuid,
  })  : _uuid = uuid,
        super(handledFailureLogWriter: logWriter);

  final Uuid _uuid;

  @override
  final TextEditingController titleController = TextEditingController();

  @override
  final TextEditingController goalController = TextEditingController();

  final ValueNotifier<DateTime> _periodStart = ValueNotifier<DateTime>(
    DateTime.now(),
  );

  final ValueNotifier<DateTime> _periodEnd = ValueNotifier<DateTime>(
    DateTime.now().add(const Duration(days: 7)),
  );

  final ValueNotifier<UnionState<void>> _saveState =
      ValueNotifier<UnionState<void>>(const UnionStateContent(null));

  @override
  ValueListenable<DateTime> get periodStartListenable => _periodStart;

  @override
  ValueListenable<DateTime> get periodEndListenable => _periodEnd;

  @override
  ValueListenable<UnionState<void>> get saveState => _saveState;

  @override
  void dispose() {
    titleController.dispose();
    goalController.dispose();
    _periodStart.dispose();
    _periodEnd.dispose();
    _saveState.dispose();
    super.dispose();
  }

  @override
  Future<void> onPickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodStart.value,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    _periodStart.value = picked;
    if (_periodEnd.value.isBefore(picked)) {
      _periodEnd.value = picked;
    }
  }

  @override
  Future<void> onPickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _periodEnd.value,
      firstDate: _periodStart.value,
      lastDate: DateTime(2100),
    );
    if (picked == null || !context.mounted) {
      return;
    }
    _periodEnd.value = picked;
  }

  @override
  Future<void> onSave() async {
    final title = titleController.text.trim();
    if (title.isEmpty) {
      snackController.addSnack(
        PlanningStrings.validationPlanTitle(context),
        messageType: SnackMessageType.warning,
      );
      return;
    }
    final goal = goalController.text.trim();
    if (goal.isEmpty) {
      snackController.addSnack(
        PlanningStrings.validationGoal(context),
        messageType: SnackMessageType.warning,
      );
      return;
    }
    _saveState.emit(const UnionStateLoading());
    final now = DateTime.now().millisecondsSinceEpoch;
    final plan = PlanningPlanEntity(
      id: _uuid.v4(),
      title: title,
      goalDescription: goal,
      periodStartMillis: _periodStart.value.millisecondsSinceEpoch,
      periodEndMillis: _periodEnd.value.millisecondsSinceEpoch,
      tasks: const <PlanningTaskEntity>[],
      createdAtMillis: now,
      updatedAtMillis: now,
    );
    try {
      await model.savePlan(plan);
      if (!context.mounted) {
        return;
      }
      _saveState.emit(const UnionStateContent(null));
      _closeScreen();
    } on Object catch (error) {
      _saveState.emit(
        UnionStateFailure(error is Exception ? error : Exception('$error')),
      );
      onErrorHandle(error);
    }
  }

  /// Закрыть экран без сохранения через диалог подтверждения.
  @override
  Future<void> onCancel() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(PlanningStrings.discardChangesTitle(dialogContext)),
        content: Text(PlanningStrings.discardChangesMessage(dialogContext)),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(PlanningStrings.cancel(dialogContext)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(PlanningStrings.discardChangesAction(dialogContext)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    _closeScreen();
  }

  void _closeScreen() {
    context.router.pop();
  }
}
