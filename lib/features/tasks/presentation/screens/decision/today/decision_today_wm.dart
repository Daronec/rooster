import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/presentation/base_widget_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/decision_task_navigation.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_model.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_screen.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_view_data.dart';
import 'package:rooster/util/app_typedefs.dart';

/// WM экрана «Сегодня».
final class DecisionTodayScreenWidgetModel
    extends BaseWidgetModel<DecisionTodayScreen, DecisionTodayScreenModel> {
  /// Создаёт WM.
  DecisionTodayScreenWidgetModel(
    super.model, {
    required super.snackController,
    required ILogWriter logWriter,
  }) : super(handledFailureLogWriter: logWriter);

  /// Состояние тела экрана.
  UnionStateListenable<DecisionTodayViewData> get bodyState => model.bodyState;

  /// Лимит карточек (синхронизация с моделью).
  ValueNotifier<int> get visibleLimitListenable => model.visibleLimitListenable;

  /// Показать ещё задачи.
  void onShowMore() {
    model.increaseVisibleLimit();
  }

  /// Открыть детали задачи.
  Future<void> onOpenTask(TaskEntity task) async {
    await DecisionTaskNavigation.openTaskDetail(context, taskId: task.id);
  }

  /// Повторить подписку после ошибки.
  void onRetryStream() => model.retryStream();
}
