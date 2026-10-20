import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/disposable_object/i_disposable_object.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_local_image_gateway.dart';
import 'package:rooster/features/tasks/domain/gateways/i_tasks_screen_expanded_group_storage.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_change_history_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/complete_task_and_consume_stock_materials_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/delete_task_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_blocked_tasks_with_reasons_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_today_ready_tasks_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/save_task_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/resolve_task_feasibility_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/watch_active_tasks_use_case.dart';

/// {@template tasks_scope.class}
/// Scope для работы с задачами — наследует [ICoreScope] и добавляет
/// task-зависимости (репозитории, use cases, gateways).
///
/// Выделен для соблюдения Interface Segregation Principle (ISP):
/// презентационный слой задач зависит от [ITasksScope], а не от
/// всего [IAppScope] с 30+ зависимостями.
/// {@endtemplate}
abstract interface class ITasksScope implements IDisposableObject {
  /// Задачи.
  ITasksRepository get tasksRepository;

  /// Списки задач.
  ITaskListsRepository get taskListsRepository;

  /// История изменений задач.
  ITaskChangeHistoryRepository get taskChangeHistoryRepository;

  /// Локальный бюджет периода (Hive, без sync queue).
  IBudgetRepository get budgetRepository;

  /// Локальный склад материалов (Hive, без sync queue).
  IMaterialStockRepository get materialStockRepository;

  /// Расчёт выполнимости одной задачи с загрузкой бюджета/склада.
  ResolveTaskFeasibilityUseCase get resolveTaskFeasibilityUseCase;

  /// Топ готовых задач («Сегодня»).
  ListTodayReadyTasksUseCase get listTodayReadyTasksUseCase;

  /// Заблокированные задачи с причинами.
  ListBlockedTasksWithReasonsUseCase get listBlockedTasksWithReasonsUseCase;

  /// Завершение задачи с списанием материалов со склада.
  CompleteTaskAndConsumeStockMaterialsUseCase
  get completeTaskAndConsumeStockMaterialsUseCase;

  /// Сохранение или обновление задачи.
  SaveTaskUseCase get saveTaskUseCase;

  /// Удаление задачи.
  DeleteTaskUseCase get deleteTaskUseCase;

  /// Наблюдение за активными задачами (фильтрация + сортировка).
  WatchActiveTasksUseCase get watchActiveTasksUseCase;

  /// Память развёрнутой группы на экране задач.
  ITasksScreenExpandedGroupStorage get tasksScreenExpandedGroupStorage;

  /// Локальное сохранение вложений задач (копирование в каталог приложения).
  ITaskLocalImageGateway get taskLocalImageGateway;

  /// Очередь синхронизации (dev / диагностика).
  ISyncQueue get syncQueue;

  /// Менеджер синхронизации.
  ISyncManager get syncManager;

  /// [Listenable] статуса синка ([ChangeNotifier] реализации менеджера).
  Listenable get syncEngineListenable;
}

/// {@template tasks_scope_impl.class}
/// Реализация [ITasksScope].
/// {@endtemplate}
final class TasksScope implements ITasksScope {
  /// {@macro tasks_scope_impl.class}
  const TasksScope({
    required this.tasksRepository,
    required this.taskListsRepository,
    required this.taskChangeHistoryRepository,
    required this.budgetRepository,
    required this.materialStockRepository,
    required this.resolveTaskFeasibilityUseCase,
    required this.listTodayReadyTasksUseCase,
    required this.listBlockedTasksWithReasonsUseCase,
    required this.completeTaskAndConsumeStockMaterialsUseCase,
    required this.saveTaskUseCase,
    required this.deleteTaskUseCase,
    required this.watchActiveTasksUseCase,
    required this.tasksScreenExpandedGroupStorage,
    required this.taskLocalImageGateway,
    required this.syncQueue,
    required this.syncManager,
    required this.syncEngineListenable,
  });

  @override
  final ITasksRepository tasksRepository;

  @override
  final ITaskListsRepository taskListsRepository;

  @override
  final ITaskChangeHistoryRepository taskChangeHistoryRepository;

  @override
  final IBudgetRepository budgetRepository;

  @override
  final IMaterialStockRepository materialStockRepository;

  @override
  final ResolveTaskFeasibilityUseCase resolveTaskFeasibilityUseCase;

  @override
  final ListTodayReadyTasksUseCase listTodayReadyTasksUseCase;

  @override
  final ListBlockedTasksWithReasonsUseCase listBlockedTasksWithReasonsUseCase;

  @override
  final CompleteTaskAndConsumeStockMaterialsUseCase
  completeTaskAndConsumeStockMaterialsUseCase;

  @override
  final SaveTaskUseCase saveTaskUseCase;

  @override
  final DeleteTaskUseCase deleteTaskUseCase;

  @override
  final WatchActiveTasksUseCase watchActiveTasksUseCase;

  @override
  final ITasksScreenExpandedGroupStorage tasksScreenExpandedGroupStorage;

  @override
  final ITaskLocalImageGateway taskLocalImageGateway;

  @override
  final ISyncQueue syncQueue;

  @override
  final ISyncManager syncManager;

  @override
  final Listenable syncEngineListenable;

  @override
  void dispose() {
    // Lifetime управляется на уровне приложения.
  }
}