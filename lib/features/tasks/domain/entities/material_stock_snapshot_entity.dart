import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';

/// Снимок склада материалов для синхронизации с облаком.
final class MaterialStockSnapshotEntity {
  /// Создаёт снимок.
  const MaterialStockSnapshotEntity({
    required this.items,
    required this.contentRevision,
    required this.updatedAtMillis,
  });

  /// Позиции на складе.
  final List<MaterialStockItemEntity> items;

  /// Ревизия содержимого для разрешения конфликтов.
  final int contentRevision;

  /// Время последнего изменения (epoch ms).
  final int updatedAtMillis;
}
