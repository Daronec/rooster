import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_shortage_entity.dart';

/// Снимок загруженных данных для формы «Ресурсы».
final class DecisionResourcesSnapshotEntity {
  /// Создаёт снимок.
  const DecisionResourcesSnapshotEntity({
    required this.materials,
    required this.materialShortages,
    required this.revision,
    this.budget,
  });

  /// Текущий период или null.
  final BudgetPeriodEntity? budget;

  /// Позиции склада.
  final List<MaterialStockItemEntity> materials;

  /// Материалы, которых не хватает для активных задач.
  final List<TaskMaterialShortageEntity> materialShortages;

  /// Версия загрузки (ключ пересоздания формы).
  final int revision;
}
