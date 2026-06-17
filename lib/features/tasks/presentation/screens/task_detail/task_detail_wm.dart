import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:photo_opener_view/photo_opener_view.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_model.dart';
import 'package:rooster/features/tasks/presentation/screens/task_detail/task_detail_screen.dart';
import 'package:rooster/features/tasks/presentation/sounds/i_task_completion_sound_player.dart';
import 'package:rooster/features/tasks/presentation/strings/task_detail_strings.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_strings.dart';
import 'package:rooster/integration/deep_links/task_deep_link_uri_builder.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:share_plus/share_plus.dart';

/// WM экрана деталей задачи.
class TaskDetailScreenWidgetModel
    extends BaseWidgetModel<TaskDetailScreen, TaskDetailScreenModel> {
  /// Создаёт WM.
  TaskDetailScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
    required ITaskCompletionSoundPlayer taskCompletionSoundPlayer,
  }) : _taskCompletionSoundPlayer = taskCompletionSoundPlayer,
       super(
         handledFailureLogWriter: logWriter,
       );

  final ITaskCompletionSoundPlayer _taskCompletionSoundPlayer;

  /// Состояние деталей.
  UnionStateListenable<TaskEntity> get detailState => model.detailState;

  /// Списки для имени списка.
  ValueNotifier<List<TaskListEntity>> get listsListenable =>
      model.listsListenable;

  /// Подзадачи текущей задачи.
  ValueNotifier<List<TaskEntity>> get subtasksListenable =>
      model.subtasksListenable;

  /// Задачи, от которых зависит текущая задача.
  ValueNotifier<List<TaskEntity>> get dependencyTasksListenable =>
      model.dependencyTasksListenable;

  /// Имя списка по [listId] или null.
  String? listNameFor(String listId) {
    for (final list in model.listsListenable.value) {
      if (list.id == listId) {
        return list.name;
      }
    }
    return null;
  }

  /// Полноэкранный просмотр вложения с масштабированием (приоритет: локальный файл, иначе URL).
  void onOpenTaskAttachmentFullscreen({
    required String? localFilePath,
    required String? networkImageUrl,
  }) {
    if (kIsWeb) {
      final url = networkImageUrl != null && networkImageUrl.isNotEmpty
          ? networkImageUrl
          : null;
      if (url == null) {
        return;
      }
      MediaViewer.openImage(context, url);
      return;
    }
    if (localFilePath != null && localFilePath.isNotEmpty) {
      MediaViewer.openImage(context, localFilePath, isNetworkImage: false);
      return;
    }
    if (networkImageUrl != null && networkImageUrl.isNotEmpty) {
      MediaViewer.openImage(context, networkImageUrl);
    }
  }

  /// Открыть редактирование.
  Future<void> onEdit() async {
    await context.router.push<void>(
      CreateTaskRoute(taskId: model.taskId),
    );
  }

  /// Поделиться диплинком задачи (открытие этой задачи в приложении).
  Future<void> onShareTask() async {
    try {
      final uri = TaskDeepLinkUriBuilder.uriForTaskId(model.taskId);
      await SharePlus.instance.share(
        ShareParams(
          text: uri.toString(),
          subject: TaskDetailStrings.shareSubject(context),
        ),
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Открыть создание подзадачи.
  Future<void> onAddSubtask() async {
    await context.router.push<void>(
      CreateTaskRoute(parentTaskId: model.taskId),
    );
  }

  /// Открыть редактирование подзадачи.
  Future<void> onEditTask(String taskId) async {
    await context.router.push<void>(
      CreateTaskRoute(taskId: taskId),
    );
  }

  /// Открыть зависимость текущей задачи.
  Future<void> onOpenDependencyTask(String taskId) async {
    await context.router.push<void>(
      TaskDetailRoute(taskId: taskId),
    );
  }

  /// Повторить загрузку после ошибки потока.
  void retryDetail() {
    unawaited(model.reloadFromRepository());
  }

  /// Переключить выполнение.
  Future<void> onToggleCompleted({
    required TaskEntity task,
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

  @override
  void dispose() {
    unawaited(_taskCompletionSoundPlayer.dispose());
    super.dispose();
  }

  /// Удалить задачу с подтверждением.
  Future<void> onConfirmDelete() async {
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
      await model.deleteTask(model.taskId);
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        TasksStrings.deleteSuccess(context),
        messageType: SnackMessageType.success,
      );
      await context.router.maybePop();
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }

  /// Удалить подзадачу с подтверждением (без закрытия экрана родителя).
  Future<void> onConfirmDeleteSubtask(TaskEntity task) async {
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
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        TasksStrings.deleteSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }
}
