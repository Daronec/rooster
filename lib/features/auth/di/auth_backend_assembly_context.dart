import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/planning/domain/entities/planning_plan_entity.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/persistence/storage/tokens_storage/token_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Данные composition root для выбора и сборки [IAuthBackendAssemblyStrategy].
final class AuthBackendAssemblyContext {
  /// Создаёт контекст.
  const AuthBackendAssemblyContext({
    required this.authBackendStrategy,
    required this.appwriteEnv,
    required this.logger,
    required this.tokenStorage,
    required this.secureStorage,
    required this.sharedPreferences,
    required this.loadTaskById,
    required this.loadListById,
    required this.loadPlanById,
    required this.loadMaterialStockSnapshot,
    required this.tasksRepository,
    required this.taskListsRepository,
    required this.planningRepository,
    required this.materialStockRepository,
  });

  /// Результат [resolveAuthBackendStrategy] (Appwrite или только локально).
  final AuthBackendStrategy authBackendStrategy;

  /// Параметры Appwrite из окружения.
  final AppwriteEnvConfig appwriteEnv;

  /// Логгер приложения.
  final ILogWriter logger;

  /// Хранилище токенов (secure).
  final ITokenStorage tokenStorage;

  /// Secure storage для сессии Appwrite.
  final FlutterSecureStorage secureStorage;

  /// Shared preferences.
  final SharedPreferences sharedPreferences;

  /// Загрузка задачи по id (локальный Hive).
  final Future<TaskEntity?> Function(String taskId) loadTaskById;

  /// Загрузка списка по id (локальный Hive).
  final Future<TaskListEntity?> Function(String listId) loadListById;

  /// Загрузка плана по id (локальный Hive).
  final Future<PlanningPlanEntity?> Function(String planId) loadPlanById;

  /// Снимок склада материалов для исходящей синхронизации.
  final Future<MaterialStockSnapshotEntity?> Function()
      loadMaterialStockSnapshot;

  /// Репозиторий задач (входящий merge и ack после push).
  final ITasksRepository tasksRepository;

  /// Репозиторий списков (входящий merge).
  final ITaskListsRepository taskListsRepository;

  /// Репозиторий планов (входящий merge).
  final IPlanningRepository planningRepository;

  /// Репозиторий склада материалов (входящий merge).
  final IMaterialStockRepository materialStockRepository;

  /// Ветка Appwrite (облачный вход).
  bool get isAppwriteAuthBranch =>
      authBackendStrategy == AuthBackendStrategy.appwrite;
}
