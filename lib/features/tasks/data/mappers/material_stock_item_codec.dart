import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';

/// Сериализация [MaterialStockItemEntity] ↔ Hive map.
final class MaterialStockItemCodec {
  const MaterialStockItemCodec._();

  /// Версия записи в списке склада.
  static const int currentSchemaVersion = 1;

  /// Карта для элемента списка в Hive.
  static Map<String, Object?> toMap(MaterialStockItemEntity entity) {
    return {
      'schemaVersion': currentSchemaVersion,
      'id': entity.id,
      'name': entity.name,
      'quantity': entity.quantity,
      'unit': entity.unit,
    };
  }

  /// Восстановление одной позиции.
  static MaterialStockItemEntity fromMap(Map<String, dynamic> map) {
    return MaterialStockItemEntity(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      quantity: _readQuantity(map['quantity']),
      unit: map['unit'] as String?,
    );
  }

  static double _readQuantity(Object? raw) {
    final value = (raw as num?)?.toDouble();
    if (value == null || value.isNaN) {
      return 0;
    }
    return value < 0 ? 0 : value;
  }
}
