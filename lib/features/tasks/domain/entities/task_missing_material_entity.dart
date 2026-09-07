/// Недостающий материал для объяснения блокировки.
final class TaskMissingMaterialEntity {
  /// Создаёт запись.
  const TaskMissingMaterialEntity({
    required this.label,
    required this.missingQuantity,
  });

  /// Человекочитаемое название материала (или fallback).
  final String label;

  /// Сколько не хватает (положительное число).
  final double missingQuantity;
}





