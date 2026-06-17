import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';

/// Правило «кто новее» при входящей синхронизации склада с Appwrite.
abstract final class MaterialStockRemoteMergePolicy {
  /// Возвращает `true`, если удалённый снимок должен заменить локальный склад.
  static bool remoteStockWins({
    required MaterialStockSnapshotEntity? local,
    required MaterialStockSnapshotEntity remote,
  }) {
    if (local == null) {
      return true;
    }
    if (remote.updatedAtMillis > local.updatedAtMillis) {
      return true;
    }
    if (remote.updatedAtMillis < local.updatedAtMillis) {
      return false;
    }
    return remote.contentRevision >= local.contentRevision;
  }
}
