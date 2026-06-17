import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/core/sync/sync_auth_required_exception.dart';
import 'package:rooster/core/sync/sync_backoff.dart';
import 'package:rooster/core/sync/sync_status.dart';
import 'package:rooster/integration/network/connectivity_gateway.dart';

/// Оркестратор очереди: сеть, exponential backoff, обработка ошибок.
final class SyncManagerImpl extends ChangeNotifier implements ISyncManager {
  /// Создаёт менеджер.
  SyncManagerImpl({
    required ISyncQueue syncQueue,
    required ISyncRemoteExecutor remoteExecutor,
    required IConnectivityGateway connectivity,
    required ILogWriter logger,
    SyncBackoff? backoff,
  })  : _syncQueue = syncQueue,
        _remoteExecutor = remoteExecutor,
        _connectivity = connectivity,
        _logger = logger,
        _backoff = backoff ?? SyncBackoff() {
    _subscription = _connectivity.onOnline.listen(_onConnectivity);
  }

  final ISyncQueue _syncQueue;
  final ISyncRemoteExecutor _remoteExecutor;
  final IConnectivityGateway _connectivity;
  final ILogWriter _logger;
  final SyncBackoff _backoff;

  late final StreamSubscription<bool> _subscription;
  bool _paused = false;
  bool _running = false;
  SyncEngineStatus _status = SyncEngineStatus.idleOffline;

  @override
  SyncEngineStatus get status => _status;

  void _setStatus(SyncEngineStatus next) {
    if (_status == next) {
      return;
    }
    _status = next;
    notifyListeners();
  }

  void _onConnectivity(bool online) {
    if (online && !_paused) {
      unawaited(requestSync());
    } else if (!online) {
      _setStatus(SyncEngineStatus.idleOffline);
    }
  }

  @override
  void setPaused(bool paused) {
    _paused = paused;
    if (paused) {
      _setStatus(SyncEngineStatus.idleOffline);
    } else {
      unawaited(requestSync());
    }
  }

  @override
  Future<void> requestSync() async {
    if (_running || _paused) {
      return;
    }
    final online = await _connectivity.isOnline();
    if (!online) {
      _setStatus(SyncEngineStatus.idleOffline);
      return;
    }

    _running = true;
    _setStatus(SyncEngineStatus.syncing);

    try {
      final ops = await _syncQueue.loadAll();
      if (ops.isEmpty) {
        _setStatus(SyncEngineStatus.idleSynced);
        return;
      }

      var hadError = false;
      syncDrain:
      while (!_paused && await _connectivity.isOnline()) {
        final batch = await _syncQueue.loadAll();
        if (batch.isEmpty) {
          break;
        }
        final op = batch.first;
        final result = await _remoteExecutor.execute(op);
        switch (result) {
          case ResultOk():
            await _syncQueue.remove(op.id);
            if (kDebugMode) {
              _logger.log('sync_ok ${op.type.name} ${op.id}');
            }
          case ResultFailed(:final failure):
            if (failure.original is SyncAuthRequiredException) {
              hadError = true;
              if (kDebugMode) {
                _logger.log(
                  'sync_paused_auth_required ${op.type.name} ${op.id}',
                );
              }
              break syncDrain;
            }
            hadError = true;
            final delay = _backoff.delayForAttempt(op.attemptCount + 1);
            final updated = op.copyWith(
              attemptCount: op.attemptCount + 1,
              lastError: failure.original.toString(),
            );
            await _syncQueue.update(updated);
            if (kDebugMode) {
              _logger.log(
                'sync_fail ${op.type.name} attempt=${updated.attemptCount} '
                'delayMs=${delay.inMilliseconds} err=${failure.original}',
              );
            }
            await Future<void>.delayed(delay);
        }
      }
      _setStatus(
        hadError ? SyncEngineStatus.degraded : SyncEngineStatus.idleSynced,
      );
    } finally {
      _running = false;
    }
  }

  @override
  void dispose() {
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
