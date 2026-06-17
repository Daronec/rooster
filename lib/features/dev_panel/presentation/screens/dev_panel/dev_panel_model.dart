import 'package:elementary/elementary.dart';
import 'package:rooster/core/sync/i_sync_queue.dart';
import 'package:rooster/core/sync/sync_operation.dart';

/// Модель dev-панели.
final class DevPanelScreenModel extends ElementaryModel {
  /// Создаёт модель.
  DevPanelScreenModel({required ISyncQueue syncQueue}) : _syncQueue = syncQueue;

  final ISyncQueue _syncQueue;

  /// Загрузить очередь.
  Future<List<SyncOperation>> loadQueue() => _syncQueue.loadAll();
}
