import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';

/// Локальный склад материалов и синхронизация снимка с облаком.
abstract interface class IMaterialStockRepository {
  /// Все позиции; пустой список — склад не заведён.
  Future<List<MaterialStockItemEntity>> readAllItems();

  /// Полная замена списка позиций на диске и постановка в очередь синхронизации.
  Future<void> saveAllItems(List<MaterialStockItemEntity> items);

  /// Входящая синхронизация: заменить локальный склад, если снимок с облака новее.
  Future<void> mergeRemoteStockIfNewer(MaterialStockSnapshotEntity remote);
}
