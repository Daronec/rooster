import 'package:auto_route/auto_route.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_model.dart';
import 'package:rooster/features/tasks/presentation/screens/task_change_history/task_change_history_screen.dart';
import 'package:rooster/util/app_typedefs.dart';

/// WM экрана истории изменений задачи.
class TaskChangeHistoryScreenWidgetModel extends BaseWidgetModel<
    TaskChangeHistoryScreen,
    TaskChangeHistoryScreenModel> {
  /// Создаёт WM.
  TaskChangeHistoryScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(handledFailureLogWriter: logWriter);

  /// Id задачи.
  String get taskId => model.taskId;

  /// Состояние истории.
  UnionStateListenable<List<TaskChangeEntity>> get changesState =>
      model.changesState;

  /// Повторить загрузку.
  void onRetry() => model.retry();

  /// Закрыть экран.
  Future<void> onClose() async {
    await context.router.maybePop();
  }
}



