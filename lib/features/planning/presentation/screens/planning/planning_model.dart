import 'dart:async';

import 'package:elementary/elementary.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/util/union_state/empty_screen_body.dart';
import 'package:union_state/union_state.dart';

/// Модель экрана планирования.
final class PlanningScreenModel extends ElementaryModel {
  /// Создаёт модель.
  PlanningScreenModel({
    required IPlanningRepository planningRepository,
    required ITasksRepository tasksRepository,
  }) : _planningRepository = planningRepository,
       _tasksRepository = tasksRepository;

  final IPlanningRepository _planningRepository;
  final ITasksRepository _tasksRepository;

  StreamSubscription<List<PlanningPlanEntity>>? _plansSubscription;

  /// Планы для UI.
  final ValueNotifier<List<PlanningPlanEntity>> plansListenable =
      ValueNotifier<List<PlanningPlanEntity>>(<PlanningPlanEntity>[]);

  /// Состояние экрана.
  final UnionStateNotifier<EmptyScreenBody> bodyState =
      UnionStateNotifier<EmptyScreenBody>.loading();

  @override
  void init() {
    super.init();
    subscribePlans();
  }

  /// Повторно подписаться на планы.
  void subscribePlans() {
    _plansSubscription?.cancel();
    bodyState.loading();
    _plansSubscription = _planningRepository.watchPlans().listen(
      (plans) {
        plansListenable.value = plans;
        bodyState.content(EmptyScreenBody.instance);
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

  /// Сохранить план.
  Future<void> savePlan(PlanningPlanEntity plan) {
    return _planningRepository.savePlan(plan);
  }

  /// Загрузить задачу по id.
  Future<TaskEntity?> loadTask(String taskId) {
    return _tasksRepository.loadTask(taskId);
  }

  /// Сохранить задачу в общем хранилище задач.
  Future<void> saveTask(TaskEntity task) {
    return _tasksRepository.saveTask(task);
  }

  /// Удалить план.
  Future<void> deletePlan(String planId) {
    return _planningRepository.deletePlan(planId);
  }

  @override
  void dispose() {
    _plansSubscription?.cancel();
    _plansSubscription = null;
    plansListenable.dispose();
    bodyState.dispose();
    super.dispose();
  }
}
