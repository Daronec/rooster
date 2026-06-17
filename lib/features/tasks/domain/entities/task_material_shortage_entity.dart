/// Агрегированный дефицит материала по активным задачам.
final class TaskMaterialShortageEntity {
  /// Создаёт запись дефицита.
  const TaskMaterialShortageEntity({
    required this.label,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.missingQuantity,
    required this.taskCount,
  });

  /// Человекочитаемое название материала.
  final String label;

  /// Сколько всего требуется по задачам.
  final double requiredQuantity;

  /// Сколько есть в ресурсах.
  final double availableQuantity;

  /// Сколько не хватает.
  final double missingQuantity;

  /// Сколько задач требует этот материал.
  final int taskCount;
}
