import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/gateways/i_tasks_screen_expanded_group_storage.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_blocked_tasks_with_reasons_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_today_ready_tasks_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/complete_task_and_consume_stock_materials_use_case.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Модель списка задач.
final class TasksScreenModel extends ElementaryModel {
  /// Создаёт модель.
  TasksScreenModel({
    required ITasksRepository tasksRepository,
    required ITaskListsRepository taskListsRepository,
    required ITasksScreenExpandedGroupStorage expandedGroupStorage,
    required ListTodayReadyTasksUseCase listTodayReadyTasksUseCase,
    required ListBlockedTasksWithReasonsUseCase
        listBlockedTasksWithReasonsUseCase,
    required CompleteTaskAndConsumeStockMaterialsUseCase
        completeTaskAndConsumeStockMaterialsUseCase,
  }) : _tasksRepository = tasksRepository,
       _taskListsRepository = taskListsRepository,
       _expandedGroupStorage = expandedGroupStorage,
       _listTodayReadyTasksUseCase = listTodayReadyTasksUseCase,
       _listBlockedTasksWithReasonsUseCase =
           listBlockedTasksWithReasonsUseCase,
       _completeTaskAndConsumeStockMaterialsUseCase =
           completeTaskAndConsumeStockMaterialsUseCase;

  final ITasksRepository _tasksRepository;
  final ITaskListsRepository _taskListsRepository;
  final ITasksScreenExpandedGroupStorage _expandedGroupStorage;
  final ListTodayReadyTasksUseCase _listTodayReadyTasksUseCase;
  final ListBlockedTasksWithReasonsUseCase _listBlockedTasksWithReasonsUseCase;
  final CompleteTaskAndConsumeStockMaterialsUseCase
      _completeTaskAndConsumeStockMaterialsUseCase;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;
  StreamSubscription<List<TaskListEntity>>? _listsSubscription;

  /// Актуальный список задач для UI ([ValueListenable]).
  final ValueNotifier<List<TaskEntity>> tasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  /// Списки задач (имена и цвета для групп).
  final ValueNotifier<List<TaskListEntity>> taskListsListenable =
      ValueNotifier<List<TaskListEntity>>(<TaskListEntity>[]);

  /// Id развёрнутых групп; пустой набор — все свёрнуты.
  final ValueNotifier<Set<String>> expandedListIdsListenable =
      ValueNotifier<Set<String>>(<String>{});

  /// Превью «Сегодня» для отладочной панели ([kDebugMode]).
  final ValueNotifier<List<TaskFeasibilityListEntryEntity>>
      todayReadyPreviewListenable =
      ValueNotifier<List<TaskFeasibilityListEntryEntity>>(
    <TaskFeasibilityListEntryEntity>[],
  );

  /// Превью заблокированных задач для отладочной панели ([kDebugMode]).
  final ValueNotifier<List<TaskFeasibilityListEntryEntity>>
      blockedPreviewListenable =
      ValueNotifier<List<TaskFeasibilityListEntryEntity>>(
    <TaskFeasibilityListEntryEntity>[],
  );

  /// Состояние тела экрана: первая выдача потока / ошибка / успех.
  final UnionStateNotifier<EmptyScreenBody> bodyState =
      UnionStateNotifier<EmptyScreenBody>.loading();

  @override
  void init() {
    super.init();
    unawaited(_restoreExpandedListIds());
    _subscribeTaskLists();
    _subscribeTasks();
  }

  Future<void> _restoreExpandedListIds() async {
    final ids = await _expandedGroupStorage.loadExpandedListIds();
    expandedListIdsListenable.value = Set<String>.from(ids);
  }

  void _subscribeTaskLists() {
    _listsSubscription?.cancel();
    _listsSubscription = _taskListsRepository.watchLists().listen(
      (lists) {
        taskListsListenable.value = lists;
        _reconcileExpandedGroup();
      },
      onError: (Object error, StackTrace stackTrace) {
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  void _subscribeTasks() {
    _tasksSubscription?.cancel();
    bodyState.loading();
    _tasksSubscription = _tasksRepository.watchTasks().listen(
      (tasks) {
        tasksListenable.value = tasks
            .where((task) => task.parentTaskId == null || task.parentTaskId!.isEmpty)
            .where(
              (task) =>
                  task.status != TaskStatusEntity.archived,
            )
            .toList(growable: false);
        bodyState.content(EmptyScreenBody.instance);
        _reconcileExpandedGroup();
        if (kDebugMode) {
          unawaited(_refreshDecisionPreviews(tasks));
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        bodyState.failure(
          error is Exception ? error : Exception(error.toString()),
          null,
        );
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  void _reconcileExpandedGroup() {
    final current = expandedListIdsListenable.value;
    if (current.isEmpty) {
      return;
    }
    final byListId = _tasksByListId(
      tasksListenable.value,
    );
    final next = current
        .where((listId) {
          final bucket = byListId[listId];
          return bucket != null && bucket.isNotEmpty;
        })
        .toSet();
    if (next.length != current.length) {
      unawaited(setExpandedListIds(next));
    }
  }

  /// Сохранить набор развёрнутых групп.
  Future<void> setExpandedListIds(Set<String> listIds) async {
    expandedListIdsListenable.value = Set<String>.from(listIds);
    await _expandedGroupStorage.saveExpandedListIds(listIds);
  }

  /// Реакция на раскрытие/сворачивание группы в UI.
  Future<void> applyListGroupExpansion({
    required String listId,
    required bool expanded,
  }) async {
    final next = Set<String>.from(expandedListIdsListenable.value);
    if (expanded) {
      next.add(listId);
    } else {
      next.remove(listId);
    }
    await setExpandedListIds(next);
  }

  /// Повторная подписка после ошибки потока задач.
  void retryTasksStream() {
    _subscribeTasks();
  }

  Future<void> _refreshDecisionPreviews(List<TaskEntity> tasks) async {
    final tasksById = <String, TaskEntity>{
      for (final task in tasks) task.id: task,
    };
    try {
      final todayEntries = await _listTodayReadyTasksUseCase.execute(
        tasksById: tasksById,
      );
      final blockedEntries =
          await _listBlockedTasksWithReasonsUseCase.execute(
        tasksById: tasksById,
      );
      todayReadyPreviewListenable.value = todayEntries;
      blockedPreviewListenable.value = blockedEntries.length > 5
          ? blockedEntries.sublist(0, 5)
          : blockedEntries;
    } on Object catch (error, stackTrace) {
      handleError(error, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _listsSubscription?.cancel();
    _listsSubscription = null;
    tasksListenable.dispose();
    taskListsListenable.dispose();
    expandedListIdsListenable.dispose();
    todayReadyPreviewListenable.dispose();
    blockedPreviewListenable.dispose();
    bodyState.dispose();
    super.dispose();
  }

  /// Удалить задачу локально и поставить операцию в очередь синхронизации.
  Future<void> deleteTask(String taskId) => _tasksRepository.deleteTask(taskId);

  /// Сохранить задачу локально и поставить upsert в очередь синхронизации.
  Future<void> saveTask(TaskEntity task) => _tasksRepository.saveTask(task);

  /// Переключить выполнение задачи с учётом склада.
  Future<void> setTaskCompleted({
    required TaskEntity task,
    required bool completed,
  }) {
    return _completeTaskAndConsumeStockMaterialsUseCase.execute(
      task: task,
      completed: completed,
    );
  }
}

Map<String, List<TaskEntity>> _tasksByListId(List<TaskEntity> tasks) {
  final map = <String, List<TaskEntity>>{};
  for (final task in tasks) {
    map.putIfAbsent(task.listId, () => <TaskEntity>[]).add(task);
  }
  return map;
}
