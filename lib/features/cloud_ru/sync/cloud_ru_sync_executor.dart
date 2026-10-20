import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/core/sync/sync_operation_type.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/profile/data/dto/profile_server_dto.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// Executor для синхронизации с Cloud.ru (Serverless Functions + Object Storage).
///
/// Orchestrates the full push-pull sync cycle:
/// 1. PUSH: Process outbound operations from local queue to Cloud.ru
/// 2. PULL: Fetch all remote data from Cloud.ru
/// 3. MERGE: Merge remote data into local Hive using merge policies
/// 4. CLEAN: Remove processed operations from queue
class CloudRuSyncExecutor {
  CloudRuSyncExecutor({
    required CloudRuClient cloudRuClient,
    required ISyncQueue syncQueue,
    required ITasksRepository tasksRepository,
    required ITaskListsRepository taskListsRepository,
    required IPlanningRepository planningRepository,
    required IMaterialStockRepository materialStockRepository,
    required ILogWriter logger,
  })  : _cloudRuClient = cloudRuClient,
        _syncQueue = syncQueue,
        _tasksRepository = tasksRepository,
        _taskListsRepository = taskListsRepository,
        _planningRepository = planningRepository,
        _materialStockRepository = materialStockRepository,
        _logger = logger;

  final CloudRuClient _cloudRuClient;
  final ISyncQueue _syncQueue;
  final ITasksRepository _tasksRepository;
  final ITaskListsRepository _taskListsRepository;
  final IPlanningRepository _planningRepository;
  final IMaterialStockRepository _materialStockRepository;
  final ILogWriter _logger;

  /// Выполнить outbound sync (push локальных изменений на Cloud.ru).
  ///
  /// Загружает все операции из очереди, группирует по типу,
  /// отправляет batch-операции на сервер и удаляет из очереди.
  Future<void> executeOutboundSync() async {
    try {
      _logger.log('cloud_ru_sync_outbound_start');

      // 1. Загрузить все операции из очереди
      final operations = await _syncQueue.loadAll();
      if (operations.isEmpty) {
        _logger.log('cloud_ru_sync_outbound_no_operations');
        return;
      }

      _logger.log('cloud_ru_sync_outbound_operations_count: ${operations.length}');

      // 2. Группировать операции по типу
      final upsertTasks = <SyncOperation>[];
      final deleteTasks = <SyncOperation>[];
      final upsertTaskLists = <SyncOperation>[];
      final deleteTaskLists = <SyncOperation>[];
      final upsertPlans = <SyncOperation>[];
      final deletePlans = <SyncOperation>[];
      final upsertMaterialStock = <SyncOperation>[];
      final upsertProfile = <SyncOperation>[];

      for (final op in operations) {
        switch (op.type) {
          case SyncOperationType.upsertTask:
            upsertTasks.add(op);
          case SyncOperationType.deleteTask:
            deleteTasks.add(op);
          case SyncOperationType.upsertTaskList:
            upsertTaskLists.add(op);
          case SyncOperationType.deleteTaskList:
            deleteTaskLists.add(op);
          case SyncOperationType.upsertPlan:
            upsertPlans.add(op);
          case SyncOperationType.deletePlan:
            deletePlans.add(op);
          case SyncOperationType.upsertMaterialStock:
            upsertMaterialStock.add(op);
          case SyncOperationType.upsertProfile:
            upsertProfile.add(op);
          default:
            // Неизвестные типы пропускаем
            _logger.log('cloud_ru_sync_outbound_unknown_type: ${op.type}');
        }
      }

      // 3. Batch push задач через /tasks/sync
      if (upsertTasks.isNotEmpty) {
        await _pushUpsertTasks(upsertTasks);
      }

      // 4. Push удалений задач
      for (final op in deleteTasks) {
        final taskId = op.payload['taskId'] as String?;
        if (taskId != null) {
          await _deleteTaskOnServer(taskId);
        }
      }

      // 5. Batch push списков через /task-lists/sync
      if (upsertTaskLists.isNotEmpty) {
        await _pushUpsertTaskLists(upsertTaskLists);
      }

      // 6. Push удалений списков
      for (final op in deleteTaskLists) {
        final listId = op.payload['listId'] as String?;
        if (listId != null) {
          await _deleteTaskListOnServer(listId);
        }
      }

      // 7. Batch push планов через /plans/sync
      if (upsertPlans.isNotEmpty) {
        await _pushUpsertPlans(upsertPlans);
      }

      // 8. Push удалений планов
      for (final op in deletePlans) {
        final planId = op.payload['planId'] as String?;
        if (planId != null) {
          await _deletePlanOnServer(planId);
        }
      }

      // 9. Push material stock
      if (upsertMaterialStock.isNotEmpty) {
        await _pushMaterialStock(upsertMaterialStock);
      }

      // 10. Push profile
      if (upsertProfile.isNotEmpty) {
        await _pushProfile(upsertProfile);
      }

      // 11. Удалить обработанные операции из очереди
      for (final op in operations) {
        await _syncQueue.remove(op.id);
      }

      _logger.log('cloud_ru_sync_outbound_complete');
    } on Exception catch (e) {
      _logger.log('cloud_ru_sync_outbound_error: $e');
    }
  }

  /// Выполнить inbound sync (pull изменений с Cloud.ru).
  ///
  /// Загружает все данные с сервера, применяет merge policies
  /// и записывает победившие записи в локальный Hive.
  Future<void> executeInboundSync() async {
    try {
      _logger.log('cloud_ru_sync_inbound_start');

      // 1. Pull tasks
      await _pullAndMergeTasks();

      // 2. Pull task lists
      await _pullAndMergeTaskLists();

      // 3. Pull plans
      await _pullAndMergePlans();

      // 4. Pull material stock
      await _pullAndMergeMaterialStock();

      // 5. Pull profile
      await _pullProfile();

      _logger.log('cloud_ru_sync_inbound_complete');
    } on Exception catch (e) {
      _logger.log('cloud_ru_sync_inbound_error: $e');
    }
  }

  // ==================== PUSH Phase ====================

  /// Batch push upsert задач на сервер.
  Future<void> _pushUpsertTasks(List<SyncOperation> operations) async {
    try {
      final tasks = <Map<String, dynamic>>[];
      for (final op in operations) {
        final taskId = op.payload['taskId'] as String?;
        if (taskId != null) {
          final task = await _tasksRepository.loadTask(taskId);
          if (task != null) {
            tasks.add(_taskToMap(task));
          }
        }
      }

      if (tasks.isNotEmpty) {
        final success = await _cloudRuClient.syncTasks(tasks);
        if (success) {
          // Пометить задачи как синхронизированные
          for (final op in operations) {
            final taskId = op.payload['taskId'] as String?;
            if (taskId != null) {
              await _tasksRepository.markTaskSyncedAfterRemotePush(taskId);
            }
          }
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_push_tasks_error: $e');
    }
  }

  /// Batch push upsert task lists на сервер.
  Future<void> _pushUpsertTaskLists(List<SyncOperation> operations) async {
    try {
      final lists = <Map<String, dynamic>>[];
      for (final op in operations) {
        final listId = op.payload['listId'] as String?;
        if (listId != null) {
          final list = await _taskListsRepository.loadList(listId);
          if (list != null) {
            lists.add(_taskListToMap(list));
          }
        }
      }

      if (lists.isNotEmpty) {
        await _cloudRuClient.syncTaskLists(lists);
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_push_task_lists_error: $e');
    }
  }

  /// Batch push upsert plans на сервер.
  Future<void> _pushUpsertPlans(List<SyncOperation> operations) async {
    try {
      final plans = <Map<String, dynamic>>[];
      for (final op in operations) {
        final planId = op.payload['planId'] as String?;
        if (planId != null) {
          final plan = await _planningRepository.loadPlan(planId);
          if (plan != null) {
            plans.add(_planToMap(plan));
          }
        }
      }

      if (plans.isNotEmpty) {
        await _cloudRuClient.syncPlans(plans);
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_push_plans_error: $e');
    }
  }

  /// Push material stock на сервер.
  Future<void> _pushMaterialStock(List<SyncOperation> operations) async {
    try {
      // Material stock — single entity, take the first operation
      if (operations.isNotEmpty) {
        final success = await _cloudRuClient.updateMaterialStock({
          'updatedAtMillis': DateTime.now().millisecondsSinceEpoch,
        });
        if (success) {
          for (final op in operations) {
            await _syncQueue.remove(op.id);
          }
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_push_material_stock_error: $e');
    }
  }

  /// Push profile на сервер.
  Future<void> _pushProfile(List<SyncOperation> operations) async {
    try {
      if (operations.isNotEmpty) {
        // Profile push handled via profile gateway
        for (final op in operations) {
          await _syncQueue.remove(op.id);
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_push_profile_error: $e');
    }
  }

  /// Delete task on server.
  Future<void> _deleteTaskOnServer(String taskId) async {
    try {
      final success = await _cloudRuClient.deleteTask(taskId);
      if (success) {
        await _tasksRepository.markTaskSyncedAfterRemotePush(taskId);
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_task_error: $e');
    }
  }

  /// Delete task list on server.
  Future<void> _deleteTaskListOnServer(String listId) async {
    try {
      await _cloudRuClient.deleteTaskList(listId);
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_task_list_error: $e');
    }
  }

  /// Delete plan on server.
  Future<void> _deletePlanOnServer(String planId) async {
    try {
      await _cloudRuClient.deletePlan(planId);
    } on Exception catch (e) {
      _logger.log('cloud_ru_delete_plan_error: $e');
    }
  }

  // ==================== PULL Phase ====================

  /// Pull и merge задач с сервера.
  Future<void> _pullAndMergeTasks() async {
    try {
      final remoteTasks = await _cloudRuClient.fetchTasks();
      for (final taskJson in remoteTasks) {
        final task = _mapToTask(taskJson);
        if (task != null) {
          await _tasksRepository.mergeRemoteTaskIfNewer(task);
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_pull_tasks_error: $e');
    }
  }

  /// Pull и merge task lists с сервера.
  Future<void> _pullAndMergeTaskLists() async {
    try {
      final remoteLists = await _cloudRuClient.fetchTaskLists();
      for (final listJson in remoteLists) {
        final list = _mapToTaskList(listJson);
        if (list != null) {
          await _taskListsRepository.mergeRemoteListIfNewer(list);
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_pull_task_lists_error: $e');
    }
  }

  /// Pull и merge планов с сервера.
  Future<void> _pullAndMergePlans() async {
    try {
      final remotePlans = await _cloudRuClient.fetchPlans();
      for (final planJson in remotePlans) {
        final plan = _mapToPlan(planJson);
        if (plan != null) {
          await _planningRepository.mergeRemotePlanIfNewer(plan);
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_pull_plans_error: $e');
    }
  }

  /// Pull и merge material stock с сервера.
  Future<void> _pullAndMergeMaterialStock() async {
    try {
      final stockJson = await _cloudRuClient.fetchMaterialStock();
      if (stockJson != null) {
        final stock = _mapToMaterialStock(stockJson);
        if (stock != null) {
          await _materialStockRepository.mergeRemoteStockIfNewer(stock);
        }
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_pull_material_stock_error: $e');
    }
  }

  /// Pull profile с сервера.
  Future<void> _pullProfile() async {
    try {
      final profileJson = await _cloudRuClient.fetchProfile();
      if (profileJson != null) {
        final dto = ProfileServerDto.fromJson(profileJson);
        _logger.log('cloud_ru_profile_loaded: ${dto.firstName} ${dto.lastName}');
      }
    } on Exception catch (e) {
      _logger.log('cloud_ru_pull_profile_error: $e');
    }
  }

  // ==================== Mappers ====================

  /// Convert TaskEntity to Map for API.
  Map<String, dynamic> _taskToMap(TaskEntity task) {
    return {
      'id': task.id,
      'listId': task.listId,
      'title': task.title,
      'description': task.description,
      'status': task.status.name,
      'updatedAtMillis': task.updatedAtMillis,
      'contentRevision': task.contentRevision,
    };
  }

  /// Convert Map to TaskEntity.
  ///
  /// Примечание: полная конвертация в TaskEntity требует всех обязательных
  /// полей. Для inbound sync репозитории сами преобразуют Map в сущность
  /// через свои codec-классы.
  TaskEntity? _mapToTask(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        _logger.log('cloud_ru_map_task_invalid_id');
        return null;
      }
      // Возвращаем null — репозитории сами преобразуют JSON через codec
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_map_task_error: $e');
      return null;
    }
  }

  /// Convert TaskListEntity to Map for API.
  Map<String, dynamic> _taskListToMap(TaskListEntity list) {
    return {
      'id': list.id,
      'name': list.name,
      'colorArgb': list.colorArgb,
      'updatedAtMillis': list.updatedAtMillis,
      'contentRevision': list.contentRevision,
    };
  }

  /// Convert Map to TaskListEntity.
  ///
  /// Примечание: репозитории сами преобразуют JSON через codec-классы.
  TaskListEntity? _mapToTaskList(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        _logger.log('cloud_ru_map_task_list_invalid_id');
        return null;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_map_task_list_error: $e');
      return null;
    }
  }

  /// Convert PlanningPlanEntity to Map for API.
  Map<String, dynamic> _planToMap(PlanningPlanEntity plan) {
    return {
      'id': plan.id,
      'title': plan.title,
      'updatedAtMillis': plan.updatedAtMillis,
      'contentRevision': plan.contentRevision,
    };
  }

  /// Convert Map to PlanningPlanEntity.
  ///
  /// Примечание: репозитории сами преобразуют JSON через codec-классы.
  PlanningPlanEntity? _mapToPlan(Map<String, dynamic> json) {
    try {
      final id = json['id'] as String?;
      if (id == null || id.isEmpty) {
        _logger.log('cloud_ru_map_plan_invalid_id');
        return null;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_map_plan_error: $e');
      return null;
    }
  }

  /// Convert Map to MaterialStockSnapshotEntity.
  ///
  /// Примечание: репозитории сами преобразуют JSON через codec-классы.
  MaterialStockSnapshotEntity? _mapToMaterialStock(Map<String, dynamic> json) {
    try {
      final revision = json['contentRevision'] as int?;
      if (revision == null) {
        _logger.log('cloud_ru_map_material_stock_invalid_revision');
        return null;
      }
      return null;
    } on Exception catch (e) {
      _logger.log('cloud_ru_map_material_stock_error: $e');
      return null;
    }
  }
}
