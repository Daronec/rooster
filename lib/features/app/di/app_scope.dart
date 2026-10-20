import 'package:rooster/features/app/di/core_scope.dart';
import 'package:rooster/features/tasks/di/tasks_scope.dart';
import 'package:rooster/features/ai/domain/gateways/i_local_llm_gateway.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/app_config.dart';
import 'package:rooster/config/environment/environment.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_vk_id_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_yandex_id_gateway.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';
import 'package:rooster/features/profile/domain/services/user_profile_service.dart';
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
import 'package:rooster/integration/network/connectivity_gateway.dart';
import 'package:rooster/persistence/storage/pin_code_storage/i_pin_code_storage.dart';
import 'package:rooster/persistence/storage/tokens_storage/token_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// {@template app_scope.class}
/// Корневой scope приложения (Task Manager + синхронизация).
///
/// Для соблюдения Interface Segregation Principle (ISP):
/// - [ICoreScope] — только инфраструктура (логгер, хранение, синк)
/// - [ITasksScope] — все task-зависимости
/// - [IAppScope] — полный интерфейс (для обратной совместимости)
///
/// [AppScope] реализует все три интерфейса.
/// {@endtemplate}
abstract interface class IAppScope implements ICoreScope, ITasksScope {
  /// Выбранная стратегия облака/входа (см. docs/AUTH_DUAL_STRATEGY_PLAN.md).
  AuthBackendStrategy get authBackendStrategy;

  /// Android и производитель указывает на Huawei/Honor: для Appwrite показываем email/пароль вместо Google OAuth.
  bool get isLikelyHuaweiOrHonorAndroidForAuthUi;

  /// Авторизация.
  IAuthGateway get authGateway;

  /// Вход через VK ID.
  IVkIdGateway get vkIdGateway;

  /// Вход через Yandex ID.
  IYandexIdGateway get yandexIdGateway;

  /// Аватар профиля (облако / локально в зависимости от бэкенда).
  IProfileAvatarGateway get profileAvatarGateway;

  /// Имя и фамиля в облаке (Appwrite).
  IProfilePersonalDataGateway get profilePersonalDataGateway;

  /// Команды пользователя.
  ITeamsGateway get teamsGateway;

  /// Объединённый сервис профиля пользователя.
  IUserProfileService get userProfileService;

  /// Планы.
  IPlanningRepository get planningRepository;

  /// Локальная LLM-модель (опционально, может быть null).
  ILocalLLMGateway? get localLLMGateway;
}

/// {@template app_scope_impl.class}
/// Реализация [IAppScope], [ICoreScope] и [ITasksScope].
/// {@endtemplate}
final class AppScope implements IAppScope {
  /// Создаёт scope.
  const AppScope({
    required this.env,
    required this.appConfig,
    required this.sharedPreferences,
    required this.logger,
    required this.localNotificationsPlugin,
    required this.tokenStorage,
    required this.pinCodeStorage,
    required this.syncQueue,
    required this.syncManager,
    required this.syncEngineListenable,
    required this.connectivityGateway,
    required this.authBackendStrategy,
    required this.isLikelyHuaweiOrHonorAndroidForAuthUi,
    required this.authGateway,
    required this.vkIdGateway,
    required this.yandexIdGateway,
    required this.profileAvatarGateway,
    required this.profilePersonalDataGateway,
    required this.teamsGateway,
    required this.userProfileService,
    required this.tasksRepository,
    required this.taskListsRepository,
    required this.planningRepository,
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
    required this.localLLMGateway,
  });

  // ICoreScope properties
  @override
  final Environment env;

  @override
  final AppConfig appConfig;

  @override
  final SharedPreferences sharedPreferences;

  @override
  final ILogWriter logger;

  @override
  final FlutterLocalNotificationsPlugin localNotificationsPlugin;

  @override
  final ITokenStorage tokenStorage;

  @override
  final IPinCodeStorage pinCodeStorage;

  @override
  final ISyncQueue syncQueue;

  @override
  final ISyncManager syncManager;

  @override
  final Listenable syncEngineListenable;

  @override
  final IConnectivityGateway connectivityGateway;

  // IAppScope properties
  @override
  final AuthBackendStrategy authBackendStrategy;

  @override
  final bool isLikelyHuaweiOrHonorAndroidForAuthUi;

  @override
  final IAuthGateway authGateway;

  @override
  final IVkIdGateway vkIdGateway;

  @override
  final IYandexIdGateway yandexIdGateway;

  @override
  final IProfileAvatarGateway profileAvatarGateway;

  @override
  final IProfilePersonalDataGateway profilePersonalDataGateway;

  @override
  final ITeamsGateway teamsGateway;

  @override
  final IUserProfileService userProfileService;

  @override
  final IPlanningRepository planningRepository;

  @override
  final ILocalLLMGateway? localLLMGateway;

  // ITasksScope properties
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
  void dispose() {
    // Lifetime управляется на уровне приложения.
  }
}
