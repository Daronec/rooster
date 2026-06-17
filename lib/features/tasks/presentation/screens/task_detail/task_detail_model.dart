import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/complete_task_and_consume_stock_materials_use_case.dart';
import 'package:union_state/union_state.dart';

/// Модель экрана деталей задачи.
final class TaskDetailScreenModel extends ElementaryModel {
  /// Создаёт модель.
  TaskDetailScreenModel({
    required this.taskId,
    required ITasksRepository tasksRepository,
    required ITaskListsRepository taskListsRepository,
    required CompleteTaskAndConsumeStockMaterialsUseCase
    completeTaskAndConsumeStockMaterialsUseCase,
  }) : _tasksRepository = tasksRepository,
       _taskListsRepository = taskListsRepository,
       _completeTaskAndConsumeStockMaterialsUseCase =
           completeTaskAndConsumeStockMaterialsUseCase;

  /// Id отображаемой задачи.
  final String taskId;

  final ITasksRepository _tasksRepository;
  final ITaskListsRepository _taskListsRepository;
  final CompleteTaskAndConsumeStockMaterialsUseCase
  _completeTaskAndConsumeStockMaterialsUseCase;

  StreamSubscription<List<TaskEntity>>? _tasksSubscription;
  StreamSubscription<List<TaskListEntity>>? _listsSubscription;

  /// Состояние загрузки / контента / ошибки.
  final UnionStateNotifier<TaskEntity> detailState =
      UnionStateNotifier<TaskEntity>.loading();

  /// Списки для отображения имени списка задачи.
  final ValueNotifier<List<TaskListEntity>> listsListenable =
      ValueNotifier<List<TaskListEntity>>(<TaskListEntity>[]);

  /// Подзадачи текущей задачи (сортировка: актуальные сверху).
  final ValueNotifier<List<TaskEntity>> subtasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  /// Задачи, от выполнения которых зависит текущая задача.
  final ValueNotifier<List<TaskEntity>> dependencyTasksListenable =
      ValueNotifier<List<TaskEntity>>(<TaskEntity>[]);

  @override
  void init() {
    super.init();
    unawaited(_loadInitialTask());
    _listsSubscription = _taskListsRepository.watchLists().listen(
      (lists) {
        listsListenable.value = lists;
      },
      onError: (Object error, StackTrace stackTrace) {
        handleError(error, stackTrace: stackTrace);
      },
    );
    _tasksSubscription = _tasksRepository.watchTasks().listen(
      _onTasksSnapshot,
      onError: (Object error, StackTrace stackTrace) {
        detailState.failure(
          error is Exception ? error : Exception(error.toString()),
          null,
        );
        handleError(error, stackTrace: stackTrace);
      },
    );
  }

  Future<void> _loadInitialTask() async {
    final task = await _tasksRepository.loadTask(taskId);
    if (task != null) {
      detailState.content(task);
    } else {
      detailState.failure(Exception('task_not_found'), null);
    }
  }

  /// Сбросить состояние и снова загрузить задачу (после ошибки потока).
  Future<void> reloadFromRepository() async {
    detailState.loading();
    await _loadInitialTask();
  }

  void _onTasksSnapshot(List<TaskEntity> tasks) {
    TaskEntity? found;
    for (final candidate in tasks) {
      if (candidate.id == taskId) {
        found = candidate;
        break;
      }
    }
    if (found != null) {
      detailState.content(found);
      final subtasks =
          tasks
              .where((task) => task.parentTaskId == taskId)
              .toList(growable: false)
            ..sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
      subtasksListenable.value = subtasks;
      dependencyTasksListenable.value = _dependencyTasksFor(
        found,
        allTasks: tasks,
      );
      return;
    }
    final current = detailState.value;
    if (current is UnionStateContent<TaskEntity>) {
      detailState.failure(Exception('task_deleted'), null);
    }
  }

  /// Сохранить изменения задачи.
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

  /// Удалить задачу.
  Future<void> deleteTask(String id) => _tasksRepository.deleteTask(id);

  @override
  void dispose() {
    _tasksSubscription?.cancel();
    _tasksSubscription = null;
    _listsSubscription?.cancel();
    _listsSubscription = null;
    listsListenable.dispose();
    subtasksListenable.dispose();
    dependencyTasksListenable.dispose();
    detailState.dispose();
    super.dispose();
  }

  List<TaskEntity> _dependencyTasksFor(
    TaskEntity task, {
    required List<TaskEntity> allTasks,
  }) {
    if (task.dependencyTaskIds.isEmpty) {
      return const [];
    }
    final tasksById = <String, TaskEntity>{
      for (final candidate in allTasks) candidate.id: candidate,
    };
    final dependencies = <TaskEntity>[];
    for (final dependencyId in task.dependencyTaskIds) {
      final dependency = tasksById[dependencyId];
      if (dependency != null) {
        dependencies.add(dependency);
      }
    }
    return List<TaskEntity>.unmodifiable(dependencies);
  }
}
