import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/app_config.dart';
import 'package:rooster/config/environment/environment.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/planning/domain/repositories/i_planning_repository.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_local_image_gateway.dart';
import 'package:rooster/features/tasks/domain/gateways/i_tasks_screen_expanded_group_storage.dart';
import 'package:rooster/features/tasks/domain/repositories/i_budget_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_change_history_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';
import 'package:rooster/features/tasks/domain/use_cases/complete_task_and_consume_stock_materials_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_blocked_tasks_with_reasons_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_today_ready_tasks_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/resolve_task_feasibility_use_case.dart';
import 'package:rooster/integration/firebase/user_presence_service.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';
import 'package:rooster/persistence/storage/pin_code_storage/i_pin_code_storage.dart';
import 'package:rooster/persistence/storage/tokens_storage/token_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Корневой scope приложения (Task Manager + синхронизация; Firebase отключён).
abstract interface class IAppScope {
  /// Окружение.
  Environment get env;

  /// Конфиг приложения.
  AppConfig get appConfig;

  /// SharedPreferences.
  SharedPreferences get sharedPreferences;

  /// Логгер.
  ILogWriter get logger;

  /// Локальные уведомления (плагин).
  FlutterLocalNotificationsPlugin get localNotificationsPlugin;

  /// Токены (secure).
  ITokenStorage get tokenStorage;

  /// PIN-хранилище (наследие инфраструктуры; можно отключить в UI).
  IPinCodeStorage get pinCodeStorage;

  /// Резерв под флаг облака (сейчас всегда false — Firebase отключён).
  bool get firebaseAvailable;

  /// Выбранная стратегия облака/входа (см. docs/AUTH_DUAL_STRATEGY_PLAN.md).
  AuthBackendStrategy get authBackendStrategy;

  /// Android и производитель указывает на Huawei/Honor: для Appwrite показываем email/пароль вместо Google OAuth.
  bool get isLikelyHuaweiOrHonorAndroidForAuthUi;

  /// Авторизация.
  IAuthGateway get authGateway;

  /// Аватар профиля (облако / локально в зависимости от бэкенда).
  IProfileAvatarGateway get profileAvatarGateway;

  /// Имя и фамилия в облаке (Appwrite).
  IProfilePersonalDataGateway get profilePersonalDataGateway;

  /// Команды Appwrite (или заглушка без облака).
  ITeamsGateway get teamsGateway;

  /// Задачи.
  ITasksRepository get tasksRepository;

  /// Списки задач.
  ITaskListsRepository get taskListsRepository;

  /// Планы.
  IPlanningRepository get planningRepository;

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

  /// Сеть.
  IConnectivityGateway get connectivityGateway;

  /// Присутствие в RTDB (заглушка; Firebase отключён).
  UserPresenceService? get userPresenceService;
}

/// Реализация [IAppScope].
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
    required this.firebaseAvailable,
    required this.authBackendStrategy,
    required this.isLikelyHuaweiOrHonorAndroidForAuthUi,
    required this.authGateway,
    required this.profileAvatarGateway,
    required this.profilePersonalDataGateway,
    required this.teamsGateway,
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
    required this.tasksScreenExpandedGroupStorage,
    required this.taskLocalImageGateway,
    required this.syncQueue,
    required this.syncManager,
    required this.syncEngineListenable,
    required this.connectivityGateway,
    required this.userPresenceService,
  });

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
  final bool firebaseAvailable;

  @override
  final AuthBackendStrategy authBackendStrategy;

  @override
  final bool isLikelyHuaweiOrHonorAndroidForAuthUi;

  @override
  final IAuthGateway authGateway;

  @override
  final IProfileAvatarGateway profileAvatarGateway;

  @override
  final IProfilePersonalDataGateway profilePersonalDataGateway;

  @override
  final ITeamsGateway teamsGateway;

  @override
  final ITasksRepository tasksRepository;

  @override
  final ITaskListsRepository taskListsRepository;

  @override
  final IPlanningRepository planningRepository;

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
  final IConnectivityGateway connectivityGateway;

  @override
  final UserPresenceService? userPresenceService;
}
