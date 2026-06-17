/// Позиция на локальном «складе» материалов.
final class MaterialStockItemEntity {
  /// Создаёт позицию.
  const MaterialStockItemEntity({
    required this.id,
    required this.name,
    required this.quantity,
    this.unit,
  });

  /// Стабильный id складской позиции; может совпадать с `stockItemId` в строке потребности задачи.
  final String id;

  /// Человекочитаемое имя.
  final String name;

  /// Количество на складе (MVP: целое неотрицательное).
  final double quantity;

  /// Единица измерения (опционально).
  final String? unit;
}
