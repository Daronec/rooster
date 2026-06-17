import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/common/utils/snack_queue/presentation/snack_message_type.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/navigation/app_router.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_model.dart';
import 'package:rooster/features/tasks/presentation/screens/task_lists/task_lists_screen.dart';
import 'package:rooster/features/tasks/presentation/strings/task_lists_strings.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';

/// WM списков.
class TaskListsScreenWidgetModel
    extends BaseWidgetModel<TaskListsScreen, TaskListsScreenModel> {
  /// Создаёт WM.
  TaskListsScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(
         handledFailureLogWriter: logWriter,
       );

  /// Списки для UI.
  ValueNotifier<List<TaskListEntity>> get listsListenable =>
      model.listsListenable;

  /// Состояние тела экрана.
  UnionStateListenable<EmptyScreenBody> get bodyState => model.bodyState;

  /// Повторить загрузку после ошибки потока.
  void retryListsStream() => model.retryListsStream();

  /// Открыть экран создания списка.
  Future<void> onCreateList() async {
    await context.router.push<void>(CreateTaskListRoute());
  }

  /// Открыть экран редактирования списка.
  Future<void> onEditList(String listId) async {
    await context.router.push<void>(CreateTaskListRoute(listId: listId));
  }

  /// Удалить список после подтверждения.
  Future<void> onConfirmDeleteList(TaskListEntity list) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(TaskListsStrings.deleteConfirmTitle(context)),
          content: Text(TaskListsStrings.deleteConfirmMessage(context)),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(TaskListsStrings.deleteCancel(context)),
            ),
            FilledButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(TaskListsStrings.deleteConfirmAction(context)),
            ),
          ],
        );
      },
    );
    if (confirmed != true || !context.mounted) {
      return;
    }
    try {
      await model.deleteList(list.id);
      if (!context.mounted) {
        return;
      }
      snackController.addSnack(
        TaskListsStrings.deleteSuccess(context),
        messageType: SnackMessageType.success,
      );
    } on Object catch (error) {
      onErrorHandle(error);
    }
  }
}
