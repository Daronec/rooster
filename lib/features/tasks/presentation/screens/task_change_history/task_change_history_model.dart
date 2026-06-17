import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_change_history_repository.dart';
import 'package:union_state/union_state.dart';

/// Модель экрана истории изменений задачи.
final class TaskChangeHistoryScreenModel extends ElementaryModel {
  /// Создаёт модель.
  TaskChangeHistoryScreenModel({
    required this.taskId,
    required ITaskChangeHistoryRepository taskChangeHistoryRepository,
  }) : _taskChangeHistoryRepository = taskChangeHistoryRepository;

  /// Id задачи.
  final String taskId;

  final ITaskChangeHistoryRepository _taskChangeHistoryRepository;

  StreamSubscription<List<TaskChangeEntity>>? _subscription;

  /// Состояние списка истории.
  final ValueNotifier<UnionState<List<TaskChangeEntity>>> changesState =
      ValueNotifier<UnionState<List<TaskChangeEntity>>>(
        const UnionStateLoading<List<TaskChangeEntity>>(),
      );

  @override
  void init() {
    super.init();
    _subscription?.cancel();
    _subscription = _taskChangeHistoryRepository.watchTaskChanges(taskId).listen(
      (items) {
        changesState.value = UnionStateContent<List<TaskChangeEntity>>(items);
      },
      onError: (Object error, StackTrace stackTrace) {
        changesState.value = UnionStateFailure<List<TaskChangeEntity>>(
          error is Exception ? error : Exception(error.toString()),
        );
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  /// Перезапуск подписки (после ошибки).
  void retry() {
    changesState.value = const UnionStateLoading<List<TaskChangeEntity>>();
    init();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    changesState.dispose();
    super.dispose();
  }
}

