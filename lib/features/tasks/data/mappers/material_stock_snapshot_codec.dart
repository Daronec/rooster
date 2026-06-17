import 'package:rooster/features/tasks/data/mappers/material_stock_item_codec.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_snapshot_entity.dart';

/// Сериализация [MaterialStockSnapshotEntity] ↔ map / JSON.
final class MaterialStockSnapshotCodec {
  const MaterialStockSnapshotCodec._();

  /// Карта для Hive и Appwrite `documentJson`.
  static Map<String, Object?> toMap(MaterialStockSnapshotEntity entity) {
    return {
      'items': entity.items
          .map(MaterialStockItemCodec.toMap)
          .toList(growable: false),
      'contentRevision': entity.contentRevision,
      'updatedAtMillis': entity.updatedAtMillis,
    };
  }

  /// Восстановление из map.
  static MaterialStockSnapshotEntity fromMap(Map<String, dynamic> map) {
    final rawItems = map['items'];
    final items = <MaterialStockItemEntity>[];
    if (rawItems is List) {
      for (final entry in rawItems) {
        if (entry is Map) {
          final item = MaterialStockItemCodec.fromMap(
            Map<String, dynamic>.from(entry),
          );
          if (item.id.isNotEmpty) {
            items.add(item);
          }
        }
      }
    }
    return MaterialStockSnapshotEntity(
      items: List<MaterialStockItemEntity>.unmodifiable(items),
      contentRevision: (map['contentRevision'] as num?)?.toInt() ?? 0,
      updatedAtMillis: (map['updatedAtMillis'] as num?)?.toInt() ?? 0,
    );
  }
}
