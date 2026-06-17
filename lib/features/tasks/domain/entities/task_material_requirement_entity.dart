/// Строка потребности в материале для задачи (название, количество, стоимость строки).
///
/// [stockItemId] — при непустом значении проверяется остаток на складе по этому id;
/// `null` — позиция только в составе задачи (без проверки склада).
final class TaskMaterialRequirementEntity {
  /// Создаёт строку.
  const TaskMaterialRequirementEntity({
    required this.id,
    required this.name,
    required this.requiredQuantity,
    required this.lineCost,
    this.stockItemId,
  });

  /// Стабильный id строки в задаче (UUID).
  final String id;

  /// Наименование материала.
  final String name;

  /// Требуемое количество (единицы согласуются со складом при [stockItemId]).
  final double requiredQuantity;

  /// Стоимость этой строки для оценки бюджета задачи.
  final double lineCost;

  /// Id позиции на складе для проверки остатка; `null` — только учёт в задаче.
  final String? stockItemId;
}
