import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/tasks/domain/decision/decision_blocked_section_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_blocked_tasks_with_reasons_use_case.dart';
import 'package:union_state/union_state.dart';

/// Модель экрана «Заблокировано».
final class DecisionBlockedScreenModel extends ElementaryModel {
  /// Создаёт модель.
  DecisionBlockedScreenModel({
    required ITasksRepository tasksRepository,
    required IBudgetRepository budgetRepository,
    required ListBlockedTasksWithReasonsUseCase listBlockedTasksWithReasonsUseCase,
    ILogWriter? logWriter,
  }) : _tasksRepository = tasksRepository,
       _budgetRepository = budgetRepository,
       _listBlockedTasksWithReasonsUseCase = listBlockedTasksWithReasonsUseCase,
       _logWriter = logWriter;

  final ITasksRepository _tasksRepository;
  final IBudgetRepository _budgetRepository;
  final ListBlockedTasksWithReasonsUseCase _listBlockedTasksWithReasonsUseCase;
  final ILogWriter? _logWriter;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;
  StreamSubscription<Object?>? _budgetSubscription;
  Timer? _rebuildDebounce;
  int _rebuildGeneration = 0;

  List<TaskEntity>? _lastTasksSnapshot;

  /// Состояние UI: загрузка / список секций / ошибка.
  final UnionStateNotifier<List<DecisionBlockedSectionEntity>> bodyState =
      UnionStateNotifier<List<DecisionBlockedSectionEntity>>.loading();

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
  }

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
      unawaited(_rebuild(tasks));
    });
  }

  Future<void> _rebuild(List<TaskEntity> tasks) async {
    try {
      final tasksById = <String, TaskEntity>{
        for (final task in tasks) task.id: task,
      };
      final sections = await _listBlockedTasksWithReasonsUseCase.loadGroupedSections(
        tasksById: tasksById,
      );
      bodyState.content(sections);
      _logDebug(sections);
    } on Object catch (error, stackTrace) {
      bodyState.failure(
        error is Exception ? error : Exception(error.toString()),
        null,
      );
      handleError(error, stackTrace: stackTrace);
    }
  }

  void _logDebug(List<DecisionBlockedSectionEntity> sections) {
    if (!kDebugMode) {
      return;
    }
    final writer = _logWriter;
    if (writer == null) {
      return;
    }
    var count = 0;
    for (final section in sections) {
      count += section.entries.length;
    }
    writer.log('decision_blocked sections=${sections.length} tasks=$count');
  }

  /// Переподписаться на поток задач после сбоя.
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
    _tasksSubscription?.cancel();
    _budgetSubscription?.cancel();
    _rebuildDebounce?.cancel();
    bodyState.dispose();
    super.dispose();
  }
}
