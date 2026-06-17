import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/common/utils/logger/log_writer.dart';
import 'package:rooster/config/app_config.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/config/environment/environment.dart';
import 'package:rooster/core/analytics/i_app_analytics_gateway.dart';
import 'package:rooster/core/sync/sync_manager_impl.dart';
import 'package:rooster/core/sync/sync_manager_ref.dart';
import 'package:rooster/features/app/di/app_scope.dart';
import 'package:rooster/features/auth/di/auth_backend_assembler.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_context.dart';
import 'package:rooster/features/auth/data/google_play_services_status_gateway_impl.dart';
import 'package:rooster/features/auth/data/huawei_device_profile_gateway_impl.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/planning/data/repositories/planning_repository_impl.dart';
import 'package:rooster/features/tasks/data/gateways/task_local_image_gateway_io.dart';
import 'package:rooster/features/tasks/data/gateways/task_local_image_gateway_stub.dart';
import 'package:rooster/features/tasks/data/gateways/auth_task_change_author_provider.dart';
import 'package:rooster/features/tasks/data/gateways/task_change_author_provider_ref.dart';
import 'package:rooster/features/tasks/data/gateways/local_notifications_task_due_reminder_gateway.dart';
import 'package:rooster/features/tasks/data/repositories/budget_repository_impl.dart';
import 'package:rooster/features/tasks/data/repositories/material_stock_repository_impl.dart';
import 'package:rooster/features/tasks/data/repositories/task_change_history_repository_impl.dart';
import 'package:rooster/features/tasks/data/repositories/task_lists_repository_impl.dart';
import 'package:rooster/features/tasks/data/repositories/tasks_repository_impl.dart';
import 'package:rooster/features/tasks/data/storage/task_decision_hive_storage_constants.dart';
import 'package:rooster/features/tasks/domain/decision/calculate_task_feasibility.dart';
import 'package:rooster/features/tasks/domain/decision/default_feasibility_scoring_policy.dart';
import 'package:rooster/features/tasks/domain/use_cases/complete_task_and_consume_stock_materials_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_blocked_tasks_with_reasons_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/list_today_ready_tasks_use_case.dart';
import 'package:rooster/features/tasks/domain/use_cases/resolve_task_feasibility_use_case.dart';
import 'package:rooster/features/tasks/data/storage/tasks_screen_expanded_group_storage_impl.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/task_ids.dart';
import 'package:rooster/integration/analytics/huawei_app_analytics_gateway_impl.dart';
import 'package:rooster/integration/firebase/firebase_bootstrap.dart';
import 'package:rooster/integration/hms/hms_bootstrap.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';
import 'package:rooster/persistence/storage/pin_code_storage/pin_code_storage_impl.dart';
import 'package:rooster/persistence/storage/sync_queue_storage/sync_queue_hive_storage.dart';
import 'package:rooster/persistence/storage/tokens_storage/token_storage_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:surf_logger/surf_logger.dart' as surf_logger;
import 'package:uuid/uuid.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// {@template app_scope_register.class}
/// Сборка [IAppScope] для Task Manager.
/// {@endtemplate}
final class AppScopeRegister {
  /// {@macro app_scope_register.class}
  const AppScopeRegister();

  /// Создание scope.
  Future<IAppScope> createScope(Environment env) async {
    await Hive.initFlutter();
    final sharedPreferences = await SharedPreferences.getInstance();

    final surfLogger = surf_logger.Logger.withStrategies({
      surf_logger.SimpleLogStrategy(),
    });
    final logger = LogWriter(surfLogger);

    final gmsGateway = GooglePlayServicesStatusGatewayImpl();
    final huaweiProfileGateway = HuaweiDeviceProfileGatewayImpl();
    final huaweiHostProfile = await huaweiProfileGateway.loadProfile();
    final googlePlayServicesUsable = await gmsGateway
        .areUsableForFirebaseClients();
    final accountKitRuntimeSupported = huaweiHostProfile.isAndroidHost;
    final isHuaweiHmsBranch =
        huaweiHostProfile.isAndroidHost &&
        !googlePlayServicesUsable &&
        huaweiHostProfile.isLikelyHuaweiOrHonorDevice &&
        accountKitRuntimeSupported;

    var firebaseInitialized = false;
    if (isHuaweiHmsBranch) {
      await HmsBootstrap.initialize(logger);
    } else {
      firebaseInitialized = await FirebaseBootstrap.initialize(logger);
    }

    final appwriteEnv = AppwriteEnvConfig.fromDotenv();
    final authBackendStrategy = resolveAuthBackendStrategy(
      appwriteClientConfigured: appwriteEnv.isClientConfigured,
    );
    logger.log('auth_backend_strategy=${authBackendStrategy.name}');
    if (kDebugMode) {
      logger.log(
        'auth_probe firebase=$firebaseInitialized gms=$googlePlayServicesUsable '
        'huaweiHost=${huaweiHostProfile.isLikelyHuaweiOrHonorDevice} '
        'hms_branch=$isHuaweiHmsBranch',
      );
    }

    final tasksBox = await Hive.openBox<dynamic>('tasks_v1');
    final listsBox = await Hive.openBox<dynamic>('task_lists_v1');
    final planningBox = await Hive.openBox<dynamic>('planning_v1');
    final syncBox = await Hive.openBox<dynamic>('sync_queue_v1');
    final taskChangesBox = await Hive.openBox<dynamic>('task_changes_v1');
    final taskDecisionBox = await Hive.openBox<dynamic>(
      TaskDecisionHiveStorageConstants.boxName,
    );

    const appConfig = AppConfig();
    const uuid = Uuid();

    final syncQueueStorage = SyncQueueHiveStorage(syncBox);
    final connectivity = ConnectivityGateway();
    final syncManagerRef = SyncManagerRef();
    final taskChangeAuthorProviderRef = TaskChangeAuthorProviderRef();

    final localNotificationsPlugin = FlutterLocalNotificationsPlugin();
    final dueReminderGateway = LocalNotificationsTaskDueReminderGateway(
      plugin: localNotificationsPlugin,
      logger: logger,
    );

    IAppAnalyticsGateway? productAnalytics;
    if (isHuaweiHmsBranch) {
      productAnalytics = HuaweiAppAnalyticsGatewayImpl();
      unawaited(productAnalytics.logAppOpen());
    }

    final taskChangeHistoryRepository = TaskChangeHistoryRepositoryImpl(
      changesBox: taskChangesBox,
    );
    final tasksRepoImpl = TasksRepositoryImpl(
      tasksBox: tasksBox,
      syncQueue: syncQueueStorage,
      syncManagerRef: syncManagerRef,
      uuid: uuid,
      analytics: productAnalytics,
      dueReminderGateway: dueReminderGateway,
      taskChangeHistoryWriter: taskChangeHistoryRepository,
      taskChangeAuthorProvider: taskChangeAuthorProviderRef,
    );
    final listsRepoImpl = TaskListsRepositoryImpl(
      listsBox: listsBox,
      syncQueue: syncQueueStorage,
      syncManagerRef: syncManagerRef,
      uuid: uuid,
    );
    final planningRepoImpl = PlanningRepositoryImpl(
      planningBox: planningBox,
      syncQueue: syncQueueStorage,
      syncManagerRef: syncManagerRef,
      uuid: uuid,
    );

    final budgetRepository = BudgetRepositoryImpl(decisionBox: taskDecisionBox);
    final materialStockRepoImpl = MaterialStockRepositoryImpl(
      decisionBox: taskDecisionBox,
      syncQueue: syncQueueStorage,
      syncManagerRef: syncManagerRef,
      uuid: uuid,
    );
    const feasibilityPolicy = DefaultFeasibilityScoringPolicy();
    final feasibilityCalculator = CalculateTaskFeasibility(
      policy: feasibilityPolicy,
    );
    final resolveTaskFeasibilityUseCase = ResolveTaskFeasibilityUseCase(
      budgetRepository: budgetRepository,
      materialStockRepository: materialStockRepoImpl,
      feasibilityCalculator: feasibilityCalculator,
    );
    final listTodayReadyTasksUseCase = ListTodayReadyTasksUseCase(
      budgetRepository: budgetRepository,
      materialStockRepository: materialStockRepoImpl,
      feasibilityCalculator: feasibilityCalculator,
    );
    final listBlockedTasksWithReasonsUseCase =
        ListBlockedTasksWithReasonsUseCase(
          budgetRepository: budgetRepository,
          materialStockRepository: materialStockRepoImpl,
          feasibilityCalculator: feasibilityCalculator,
        );
    final completeTaskAndConsumeStockMaterialsUseCase =
        CompleteTaskAndConsumeStockMaterialsUseCase(
          tasksRepository: tasksRepoImpl,
          materialStockRepository: materialStockRepoImpl,
        );

    const taskLocalImageGateway = kIsWeb
        ? TaskLocalImageGatewayStub()
        : TaskLocalImageGatewayIo();

    const secureStorage = FlutterSecureStorage();
    const tokenStorage = TokenStorageImpl(secureStorage);
    const pinCodeStorage = PinCodeStorageImpl(secureStorage);

    final authAssemblyContext = AuthBackendAssemblyContext(
      authBackendStrategy: authBackendStrategy,
      appwriteEnv: appwriteEnv,
      logger: logger,
      tokenStorage: tokenStorage,
      secureStorage: secureStorage,
      sharedPreferences: sharedPreferences,
      loadTaskById: tasksRepoImpl.loadTaskById,
      loadListById: listsRepoImpl.loadListById,
      loadPlanById: planningRepoImpl.loadPlanById,
      loadMaterialStockSnapshot: materialStockRepoImpl.loadStockSnapshot,
      tasksRepository: tasksRepoImpl,
      taskListsRepository: listsRepoImpl,
      planningRepository: planningRepoImpl,
      materialStockRepository: materialStockRepoImpl,
    );
    final authAssembly = await assembleAuthBackend(authAssemblyContext);
    taskChangeAuthorProviderRef.target = AuthTaskChangeAuthorProvider(
      authGateway: authAssembly.authGateway,
    );

    final syncManager = SyncManagerImpl(
      syncQueue: syncQueueStorage,
      remoteExecutor: authAssembly.remoteExecutor,
      connectivity: connectivity,
      logger: logger,
    );
    syncManagerRef.target = syncManager;
    authAssembly.bindInboundCloudSync?.call(syncManager, connectivity);

    if (listsBox.isEmpty) {
      final now = DateTime.now().millisecondsSinceEpoch;
      await listsRepoImpl.saveList(
        TaskListEntity(
          id: TaskIds.inboxListId,
          name: 'Входящие',
          colorArgb: 0xFF6750A4,
          updatedAtMillis: now,
        ),
      );
    }

    await syncManager.requestSync();

    final isLikelyHuaweiOrHonorAndroidForAuthUi =
        huaweiHostProfile.isAndroidHost &&
        huaweiHostProfile.isLikelyHuaweiOrHonorDevice;

    return AppScope(
      env: env,
      appConfig: appConfig,
      sharedPreferences: sharedPreferences,
      logger: logger,
      localNotificationsPlugin: localNotificationsPlugin,
      tokenStorage: tokenStorage,
      pinCodeStorage: pinCodeStorage,
      firebaseAvailable: firebaseInitialized,
      authBackendStrategy: authBackendStrategy,
      isLikelyHuaweiOrHonorAndroidForAuthUi:
          isLikelyHuaweiOrHonorAndroidForAuthUi,
      authGateway: authAssembly.authGateway,
      profileAvatarGateway: authAssembly.profileAvatarGateway,
      profilePersonalDataGateway: authAssembly.profilePersonalDataGateway,
      teamsGateway: authAssembly.teamsGateway,
      tasksRepository: tasksRepoImpl,
      taskListsRepository: listsRepoImpl,
      planningRepository: planningRepoImpl,
      taskChangeHistoryRepository: taskChangeHistoryRepository,
      budgetRepository: budgetRepository,
      materialStockRepository: materialStockRepoImpl,
      resolveTaskFeasibilityUseCase: resolveTaskFeasibilityUseCase,
      listTodayReadyTasksUseCase: listTodayReadyTasksUseCase,
      listBlockedTasksWithReasonsUseCase: listBlockedTasksWithReasonsUseCase,
      completeTaskAndConsumeStockMaterialsUseCase:
          completeTaskAndConsumeStockMaterialsUseCase,
      tasksScreenExpandedGroupStorage: TasksScreenExpandedGroupStorageImpl(
        sharedPreferences,
      ),
      taskLocalImageGateway: taskLocalImageGateway,
      syncQueue: syncQueueStorage,
      syncManager: syncManager,
      syncEngineListenable: syncManager,
      connectivityGateway: connectivity,
      userPresenceService: authAssembly.userPresenceService,
    );
  }
}
