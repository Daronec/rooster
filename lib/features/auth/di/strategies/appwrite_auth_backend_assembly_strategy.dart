import 'package:appwrite/appwrite.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/features/auth/data/appwrite_auth_gateway_impl.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_context.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_result.dart';
import 'package:rooster/features/auth/di/i_auth_backend_assembly_strategy.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/profile/data/appwrite_profile_avatar_gateway_impl.dart';
import 'package:rooster/features/profile/data/appwrite_profile_personal_data_gateway_impl.dart';
import 'package:rooster/features/profile/data/appwrite_teams_gateway_impl.dart';
import 'package:rooster/integration/appwrite/appwrite_cloud_inbound_sync_coordinator.dart';
import 'package:rooster/integration/appwrite/appwrite_session_secure_storage.dart';
import 'package:rooster/integration/appwrite/appwrite_task_sync_executor.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';
import 'package:rooster/integration/sync/local_only_sync_executor.dart';

/// Appwrite Auth и синхронизация задач в Appwrite Databases (при настроенных id в `.env`).
final class AppwriteAuthBackendAssemblyStrategy
    implements IAuthBackendAssemblyStrategy {
  /// Создаёт стратегию.
  const AppwriteAuthBackendAssemblyStrategy();

  @override
  Future<AuthBackendAssemblyResult?> tryAssemble(
    AuthBackendAssemblyContext context,
  ) async {
    if (context.authBackendStrategy != AuthBackendStrategy.appwrite) {
      return null;
    }
    final env = context.appwriteEnv;
    context.logger.log(
      'appwrite_sync_configured=${env.isSyncDatabaseConfigured} '
      'db=${env.syncDatabaseId.isNotEmpty} '
      'tasks=${env.syncTasksCollectionId.isNotEmpty} '
      'lists=${env.syncListsCollectionId.isNotEmpty} '
      'plans=${env.syncPlansCollectionId.isNotEmpty} '
      'materials=${env.syncMaterialsCollectionId.isNotEmpty} '
      'bucket=${env.syncTaskImagesBucketId.isNotEmpty}',
    );
    final client = Client()
        .setEndpoint(env.publicEndpoint)
        .setProject(env.projectId);
    final account = Account(client);
    final appwriteSessionStorage =
        AppwriteSessionSecureStorage(context.secureStorage);
    final authGateway = AppwriteAuthGatewayImpl(
      client: client,
      account: account,
      envConfig: env,
      sessionStorage: appwriteSessionStorage,
      logger: context.logger,
    );
    final teamsGateway = AppwriteTeamsGatewayImpl(
      teams: Teams(client),
      account: account,
      envConfig: env,
      logger: context.logger,
    );

    final ISyncRemoteExecutor remoteExecutor;
    final void Function(ISyncManager syncManager, IConnectivityGateway connectivity)?
        bindInboundCloudSync;

    if (env.isSyncDatabaseConfigured) {
      remoteExecutor = AppwriteTaskSyncExecutor(
        client: client,
        envConfig: env,
        authGateway: authGateway,
        logger: context.logger,
        loadTaskLocal: context.loadTaskById,
        loadListLocal: context.loadListById,
        loadPlanLocal: context.loadPlanById,
        loadMaterialStockSnapshotLocal: context.loadMaterialStockSnapshot,
        onTaskPushSucceeded: (taskId) =>
            context.tasksRepository.markTaskSyncedAfterRemotePush(taskId),
      );
      bindInboundCloudSync = (syncManager, connectivity) {
        final puller = AppwriteTaskCloudPuller(
          databases: Databases(client),
          envConfig: env,
          tasksRepository: context.tasksRepository,
          taskListsRepository: context.taskListsRepository,
          planningRepository: context.planningRepository,
          materialStockRepository: context.materialStockRepository,
          logger: context.logger,
        );
        AppwriteCloudInboundSyncCoordinator(
          authGateway: authGateway,
          connectivityGateway: connectivity,
          syncManager: syncManager,
          puller: puller,
          logger: context.logger,
        ).start();
      };
    } else {
      remoteExecutor = const LocalOnlySyncExecutor();
      bindInboundCloudSync = null;
    }

    return AuthBackendAssemblyResult(
      authGateway: authGateway,
      remoteExecutor: remoteExecutor,
      profilePersonalDataGateway: AppwriteProfilePersonalDataGatewayImpl(
        account: account,
        logger: context.logger,
      ),
      profileAvatarGateway: AppwriteProfileAvatarGatewayImpl(
        sharedPreferences: context.sharedPreferences,
        logger: context.logger,
      ),
      teamsGateway: teamsGateway,
      bindInboundCloudSync: bindInboundCloudSync,
    );
  }
}
