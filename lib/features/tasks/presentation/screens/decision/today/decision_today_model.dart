import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/tasks/domain/decision/decision_today_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_today_ready_tasks_use_case.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/today/decision_today_view_data.dart';
import 'package:union_state/union_state.dart';

/// Модель экрана «Сегодня» (движок решений).
final class DecisionTodayScreenModel extends ElementaryModel {
  /// Создаёт модель.
  DecisionTodayScreenModel({
    required ITasksRepository tasksRepository,
    required IBudgetRepository budgetRepository,
    required ListTodayReadyTasksUseCase listTodayReadyTasksUseCase,
    ILogWriter? logWriter,
  }) : _tasksRepository = tasksRepository,
       _budgetRepository = budgetRepository,
       _listTodayReadyTasksUseCase = listTodayReadyTasksUseCase,
       _logWriter = logWriter;

  final ITasksRepository _tasksRepository;
  final IBudgetRepository _budgetRepository;
  final ListTodayReadyTasksUseCase _listTodayReadyTasksUseCase;
  final ILogWriter? _logWriter;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;
  StreamSubscription<Object?>? _budgetSubscription;
  Timer? _rebuildDebounce;
  int _rebuildGeneration = 0;

  /// Лимит видимых карточек (увеличивается по «Показать ещё»).
  final ValueNotifier<int> visibleLimitListenable = ValueNotifier<int>(3);

  /// Состояние списка.
  final UnionStateNotifier<DecisionTodayViewData> bodyState =
      UnionStateNotifier<DecisionTodayViewData>.loading();

  @override
  void init() {
    super.init();
    _tasksSubscription = _tasksRepository.watchTasks().listen(
      _onTasksSnapshot,
      onError: (Object error, StackTrace stackTrace) {
        bodyState.failure(
          error is Exception ? error : Exception(error.toString()),
          null,
        );
        handleError(error, stackTrace: stackTrace);
      },
    );
    _budgetSubscription = _budgetRepository.watchActivePeriod().listen(
      (_) {
        final tasks = _lastTasksSnapshot;
        if (tasks != null) {
          _scheduleRebuild(tasks);
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        handleError(error, stackTrace: stackTrace);
      },
    );
    visibleLimitListenable.addListener(_onVisibleLimitChanged);
  }

  void _onVisibleLimitChanged() {
    final tasks = _lastTasksSnapshot;
    if (tasks != null) {
      _scheduleRebuild(tasks);
    }
  }

  List<TaskEntity>? _lastTasksSnapshot;

  void _onTasksSnapshot(List<TaskEntity> tasks) {
    _lastTasksSnapshot = tasks;
    _scheduleRebuild(tasks);
  }

  void _scheduleRebuild(List<TaskEntity> tasks) {
    _rebuildGeneration++;
    final generation = _rebuildGeneration;
    _rebuildDebounce?.cancel();
    _rebuildDebounce = Timer(const Duration(seconds: 1), () {
      if (generation != _rebuildGeneration) {
        return;
      }
      unawaited(_rebuildFromSnapshot(tasks));
    });
  }

  Future<void> _rebuildFromSnapshot(List<TaskEntity> tasks) async {
    try {
      final tasksById = <String, TaskEntity>{
        for (final task in tasks) task.id: task,
      };
      final snapshot = await _listTodayReadyTasksUseCase.loadTodaySnapshot(
        tasksById: tasksById,
        visibleLimit: visibleLimitListenable.value,
      );
      bodyState.content(
        DecisionTodayViewData(
          totalReadyCount: snapshot.totalReadyCount,
          visibleEntries: snapshot.visibleEntries,
          visibleLimit: visibleLimitListenable.value,
        ),
      );
      _logDebugSnapshot(snapshot);
    } on Object catch (error, stackTrace) {
      bodyState.failure(
        error is Exception ? error : Exception(error.toString()),
        null,
      );
      handleError(error, stackTrace: stackTrace);
    }
  }

  void _logDebugSnapshot(DecisionTodaySnapshotEntity snapshot) {
    if (!kDebugMode) {
      return;
    }
    final writer = _logWriter;
    if (writer == null) {
      return;
    }
    writer.log(
      'decision_today readyTotal=${snapshot.totalReadyCount} '
      'visible=${snapshot.visibleEntries.length}',
    );
  }

  /// Увеличить лимит отображаемых карточек.
  void increaseVisibleLimit({int delta = 3}) {
    visibleLimitListenable.value += delta;
  }

  /// Повтор после ошибки потока задач.
  void retryStream() {
    bodyState.loading();
    _tasksSubscription?.cancel();
    _tasksSubscription = _tasksRepository.watchTasks().listen(
      _onTasksSnapshot,
      onError: (Object error, StackTrace stackTrace) {
        bodyState.failure(
          error is Exception ? error : Exception(error.toString()),
          null,
        );
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  @override
  void dispose() {
    visibleLimitListenable.removeListener(_onVisibleLimitChanged);
    _tasksSubscription?.cancel();
    _budgetSubscription?.cancel();
    _rebuildDebounce?.cancel();
    visibleLimitListenable.dispose();
    bodyState.dispose();
    super.dispose();
  }
}
