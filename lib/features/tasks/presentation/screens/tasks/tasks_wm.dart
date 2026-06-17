import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart' show ValueListenable, kDebugMode;
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_model.dart';
import 'package:rooster/features/tasks/presentation/screens/tasks/tasks_screen.dart';
import 'package:rooster/features/tasks/presentation/sounds/i_task_completion_sound_player.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';

/// WM списка задач.
class TasksScreenWidgetModel
    extends BaseWidgetModel<TasksScreen, TasksScreenModel> {
  /// Создаёт WM.
  TasksScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required ITaskCompletionSoundPlayer taskCompletionSoundPlayer,
  }) : _taskCompletionSoundPlayer = taskCompletionSoundPlayer,
       super(
         handledFailureLogWriter: logWriter,
       );

  final ITaskCompletionSoundPlayer _taskCompletionSoundPlayer;

  /// Список задач для UI ([ValueListenable]).
  ValueNotifier<List<TaskEntity>> get tasksListenable => model.tasksListenable;

  /// Закреплённые активные задачи (без archived).
  final ValueNotifier<List<TaskEntity>> pinnedTasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  /// Незакреплённые активные задачи (без archived).
  final ValueNotifier<List<TaskEntity>> unpinnedTasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  /// Списки задач для заголовков групп.
  ValueNotifier<List<TaskListEntity>> get taskListsListenable =>
      model.taskListsListenable;

  /// Id развёрнутых групп; пустой набор — все свёрнуты.
  ValueNotifier<Set<String>> get expandedListIdsListenable =>
      model.expandedListIdsListenable;

  /// Превью «Сегодня» (только для отладочной панели).
  ValueNotifier<List<TaskFeasibilityListEntryEntity>>
  get todayReadyPreviewListenable => model.todayReadyPreviewListenable;

  /// Превью заблокированных (только для отладочной панели).
  ValueNotifier<List<TaskFeasibilityListEntryEntity>>
  get blockedPreviewListenable => model.blockedPreviewListenable;

  /// Состояние тела экрана (загрузка / контент / ошибка потока).
  UnionStateListenable<EmptyScreenBody> get bodyState => model.bodyState;

  VoidCallback? _tasksListenerDisposer;

  @override
  void initWidgetModel() {
    super.initWidgetModel();
    void recompute() {
      final tasks = model.tasksListenable.value;
      final pinned = <TaskEntity>[];
      final unpinned = <TaskEntity>[];
      for (final task in tasks) {
        if (task.status == TaskStatusEntity.archived) {
          continue;
        }
        if (task.isPinned) {
          pinned.add(task);
        } else {
          unpinned.add(task);
        }
      }
      pinned.sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
      pinnedTasksListenable.value = pinned;
      unpinnedTasksListenable.value = unpinned;
    }

    model.tasksListenable.addListener(recompute);
    _tasksListenerDisposer = () =>
        model.tasksListenable.removeListener(recompute);
    recompute();
  }

  @override
  void dispose() {
    _tasksListenerDisposer?.call();
    _tasksListenerDisposer = null;
    pinnedTasksListenable.dispose();
    unpinnedTasksListenable.dispose();
    unawaited(_taskCompletionSoundPlayer.dispose());
    super.dispose();
  }

  /// Раскрытие или сворачивание группы по списку.
  void onTaskListGroupExpansionChanged({
    required String listId,
    required bool expanded,
  }) {
    unawaited(
      model.applyListGroupExpansion(listId: listId, expanded: expanded),
    );
  }

  /// Повторить загрузку после ошибки потока.
  void retryTasksStream() => model.retryTasksStream();

  /// Открыть экран создания задачи.
  Future<void> onAddTask() async {
    await context.router.push(CreateTaskRoute());
  }

  /// Открыть экран редактирования задачи.
  Future<void> onEditTask(String taskId) async {
    if (kDebugMode) {
      debugPrint('tasks_on_edit_task taskId=$taskId');
    }
    await context.router.push(CreateTaskRoute(taskId: taskId));
  }

  /// Открыть экран детального просмотра задачи.
  Future<void> onOpenTaskDetail(String taskId) async {
    await context.router.push<void>(TaskDetailRoute(taskId: taskId));
  }

  /// Переключить признак выполнения задачи (чекбокс в списке).
  Future<void> onToggleTaskCompleted(
    TaskEntity task, {
    required bool completed,
  }) async {
    final newStatus = completed
        ? TaskStatusEntity.completed
        : TaskStatusEntity.pending;
    if (task.status == newStatus) {
      return;
    }
    try {
      await model.setTaskCompleted(
        task: task,
        completed: completed,
      );
      if (completed) {
        unawaited(_taskCompletionSoundPlayer.playDoneTask());
      }
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Закрепить или открепить задачу.
  Future<void> onTogglePinned(TaskEntity task) async {
    try {
      await model.saveTask(
        task.copyWith(
          isPinned: !task.isPinned,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
          syncState: TaskSyncStateEntity.pendingSync,
        ),
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Отменить задачу («Не буду делать»): переводит в неактивный статус.
  Future<void> onCancelTask(TaskEntity task) async {
    if (task.status == TaskStatusEntity.cancelled ||
        task.status == TaskStatusEntity.archived) {
      return;
    }
    try {
      await model.saveTask(
        task.copyWith(
          status: TaskStatusEntity.cancelled,
          updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
          syncState: TaskSyncStateEntity.pendingSync,
        ),
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Удалить задачу после подтверждения.
  Future<void> onConfirmDeleteTask(TaskEntity task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TasksStrings.deleteConfirmTitle(context)),
          content: Text(TasksStrings.deleteConfirmMessage(context)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(TasksStrings.deleteCancel(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(TasksStrings.deleteConfirmAction(context)),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await model.deleteTask(task.id);
      snackController.addSnack(
        TasksStrings.deleteSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }
}
