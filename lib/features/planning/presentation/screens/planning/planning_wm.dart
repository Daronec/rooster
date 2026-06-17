import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/entities/planning_task_entity.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_model.dart';
import 'package:rooster/features/planning/presentation/screens/planning/planning_screen.dart';
import 'package:rooster/features/planning/presentation/strings/planning_strings.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';
import 'package:rooster/features/tasks/domain/task_ids.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';

/// WM экрана планирования.
final class PlanningScreenWidgetModel
    extends BaseWidgetModel<PlanningScreen, PlanningScreenModel> {
  /// Создаёт WM.
  PlanningScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(handledFailureLogWriter: logWriter);

  /// Планы для UI.
  ValueNotifier<List<PlanningPlanEntity>> get plansListenable =>
      model.plansListenable;

  /// Состояние экрана (loading / content / failure).
  UnionStateListenable<EmptyScreenBody> get bodyState => model.bodyState;

  /// Повторить загрузку после ошибки.
  void retryPlansStream() => model.subscribePlans();

  /// Открыть экран создания плана.
  Future<void> onCreatePlan() async {
    await context.router.push<void>(const CreatePlanRoute());
  }

  /// Открыть полноэкранный экран создания задачи для [plan].
  Future<void> onAddTask(PlanningPlanEntity plan) async {
    final task = await context.router.push<TaskEntity?>(CreateTaskRoute());
    if (task == null) {
      return;
    }
    final now = DateTime.now().millisecondsSinceEpoch;
    final planningTask = PlanningTaskEntity(
      id: task.id,
      title: task.title,
      order: plan.tasks.length,
      importance: task.importance,
      isCompleted: task.status == TaskStatusEntity.completed,
      createdAtMillis: task.updatedAtMillis,
      updatedAtMillis: task.updatedAtMillis,
    );
    final tasks = <PlanningTaskEntity>[
      ...plan.orderedTasks.where((item) => item.id != task.id),
      planningTask,
    ];
    await _savePlan(plan.copyWith(tasks: tasks, updatedAtMillis: now));
  }

  /// Переключить выполнение задачи плана.
  Future<void> onToggleTaskCompleted(
    PlanningPlanEntity plan,
    PlanningTaskEntity task, {
    required bool completed,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final tasks = plan.tasks
        .map(
          (item) => item.id == task.id
              ? item.copyWith(isCompleted: completed, updatedAtMillis: now)
              : item,
        )
        .toList(growable: false);
    await _savePlan(plan.copyWith(tasks: tasks, updatedAtMillis: now));
    await _saveTaskEntityForPlanningTask(
      task.copyWith(isCompleted: completed, updatedAtMillis: now),
    );
  }

  /// Открыть детали задачи из плана.
  Future<void> onOpenTask(PlanningTaskEntity task) async {
    try {
      await _ensureTaskEntityForPlanningTask(task);
      if (!context.mounted) {
        return;
      }
      await context.router.push<void>(TaskDetailRoute(taskId: task.id));
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Поднять задачу выше в очереди.
  Future<void> onMoveTaskUp(PlanningPlanEntity plan, String taskId) {
    return _moveTask(plan, taskId: taskId, delta: -1);
  }

  /// Опустить задачу ниже в очереди.
  Future<void> onMoveTaskDown(PlanningPlanEntity plan, String taskId) {
    return _moveTask(plan, taskId: taskId, delta: 1);
  }

  /// Удалить план с подтверждением.
  Future<void> onDeletePlan(PlanningPlanEntity plan) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(PlanningStrings.deleteConfirmTitle(dialogContext)),
        content: Text(PlanningStrings.deleteConfirmMessage(dialogContext)),
        actions: <Widget>[
          TextButton(
            onPressed: () => dialogContext.maybePop(false),
            child: Text(PlanningStrings.cancel(dialogContext)),
          ),
          FilledButton(
            onPressed: () => dialogContext.maybePop(true),
            child: Text(PlanningStrings.deleteConfirmAction(dialogContext)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await model.deletePlan(plan.id);
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Форматировать период плана для отображения в UI.
  String formatPeriod(PlanningPlanEntity plan) {
    final localizations = MaterialLocalizations.of(context);
    final start = DateTime.fromMillisecondsSinceEpoch(plan.periodStartMillis);
    final end = DateTime.fromMillisecondsSinceEpoch(plan.periodEndMillis);
    return '${localizations.formatMediumDate(start)} - '
        '${localizations.formatMediumDate(end)}';
  }

  Future<void> _moveTask(
    PlanningPlanEntity plan, {
    required String taskId,
    required int delta,
  }) async {
    final orderedTasks = plan.orderedTasks.toList(growable: true);
    final index = orderedTasks.indexWhere((task) => task.id == taskId);
    if (index < 0) {
      return;
    }
    final nextIndex = index + delta;
    if (nextIndex < 0 || nextIndex >= orderedTasks.length) {
      return;
    }
    final movedTask = orderedTasks.removeAt(index);
    orderedTasks.insert(nextIndex, movedTask);
    final now = DateTime.now().millisecondsSinceEpoch;
    final reordered = <PlanningTaskEntity>[
      for (var i = 0; i < orderedTasks.length; i++)
        orderedTasks[i].copyWith(order: i, updatedAtMillis: now),
    ];
    await _savePlan(plan.copyWith(tasks: reordered, updatedAtMillis: now));
  }

  Future<void> _savePlan(PlanningPlanEntity plan) async {
    try {
      await model.savePlan(plan);
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  Future<void> _ensureTaskEntityForPlanningTask(PlanningTaskEntity task) async {
    final existing = await model.loadTask(task.id);
    if (existing != null) {
      return;
    }
    await _saveTaskEntityForPlanningTask(task);
  }

  Future<void> _saveTaskEntityForPlanningTask(PlanningTaskEntity task) async {
    final existing = await model.loadTask(task.id);
    final status = task.isCompleted
        ? TaskStatusEntity.completed
        : TaskStatusEntity.pending;
    if (existing != null) {
      await model.saveTask(
        existing.copyWith(
          title: task.title,
          importance: task.importance,
          status: status,
          updatedAtMillis: task.updatedAtMillis,
          syncState: TaskSyncStateEntity.pendingSync,
        ),
      );
      return;
    }
    await model.saveTask(
      TaskEntity(
        id: task.id,
        listId: TaskIds.inboxListId,
        title: task.title,
        importance: task.importance,
        status: status,
        updatedAtMillis: task.updatedAtMillis,
      ),
    );
  }
}
