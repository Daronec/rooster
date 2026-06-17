import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';

/// Заглушка: пустой склад (строки без привязки к складу или без дефицита остаются валидными).
final class NoopMaterialStockRepository implements IMaterialStockRepository {
  /// Создаёт заглушку.
  const NoopMaterialStockRepository();

  @override
  Future<List<MaterialStockItemEntity>> readAllItems() async => const [];

  @override
  Future<void> saveAllItems(List<MaterialStockItemEntity> items) async {}

  @override
  Future<void> mergeRemoteStockIfNewer(
    MaterialStockSnapshotEntity remote,
  ) async {}
}
