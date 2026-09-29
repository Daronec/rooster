import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/core/sync/sync_operation.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/cloud_ru/sync/cloud_ru_sync_executor.dart';

/// Adapter that wraps [CloudRuSyncExecutor] to implement [ISyncRemoteExecutor].
final class CloudRuSyncRemoteExecutor implements ISyncRemoteExecutor {
  /// Creates the adapter.
  CloudRuSyncRemoteExecutor({
    required CloudRuSyncExecutor cloudRuSyncExecutor,
    required CloudRuClient cloudRuClient,
    required ILogWriter logger,
  }) : _cloudRuSyncExecutor = cloudRuSyncExecutor,
       _cloudRuClient = cloudRuClient,
       _logger = logger;

  final CloudRuSyncExecutor _cloudRuSyncExecutor;
  final CloudRuClient _cloudRuClient;
  final ILogWriter _logger;

  @override
  Future<Result<void, Failure<Exception>>> execute(
    SyncOperation operation,
  ) async {
    try {
      _logger.log(
        'sync_execute ${operation.type.name} ${operation.id} '
        'endpoint=${_cloudRuClient.serverlessEndpoint}',
      );

      // TODO(cloud.ru): Implement actual sync logic based on operation type
      await _cloudRuSyncExecutor.executeOutboundSync();

      return const Result.ok(null);
    } on Exception catch (e, stackTrace) {
      _logger.log('sync_execute_error: $e');
      return Result.failed(Failure(original: e, trace: stackTrace));
    }
  }
}
