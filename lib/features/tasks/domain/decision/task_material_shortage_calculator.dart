import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_shortage_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';

/// Считает материалы, которых не хватает для активных задач.
final class TaskMaterialShortageCalculator {
  const TaskMaterialShortageCalculator._();

  /// Возвращает агрегированный дефицит по всем невыполненным задачам.
  static List<TaskMaterialShortageEntity> calculate({
    required List<TaskEntity> tasks,
    required List<MaterialStockItemEntity> stockItems,
  }) {
    final stockById = <String, MaterialStockItemEntity>{
      for (final item in stockItems) item.id: item,
    };
    final stockIdByName = <String, String>{
      for (final item in stockItems) _normalize(item.name): item.id,
    };
    final totals = <String, _MaterialDemand>{};

    for (final task in tasks) {
      if (task.status == TaskStatusEntity.completed) {
        continue;
      }
      for (final requirement in task.materialRequirements) {
        final demand = _demandFromRequirement(
          taskId: task.id,
          requirement: requirement,
          stockById: stockById,
          stockIdByName: stockIdByName,
        );
        if (demand == null) {
          continue;
        }
        totals.update(
          demand.key,
          (existing) => existing.merge(demand),
          ifAbsent: () => demand,
        );
      }
    }

    final shortages = <TaskMaterialShortageEntity>[];
    for (final demand in totals.values) {
      final missing = demand.requiredQuantity - demand.availableQuantity;
      if (missing <= 0) {
        continue;
      }
      shortages.add(
        TaskMaterialShortageEntity(
          label: demand.label,
          requiredQuantity: demand.requiredQuantity,
          availableQuantity: demand.availableQuantity,
          missingQuantity: missing,
          taskCount: demand.taskIds.length,
        ),
      );
    }
    shortages.sort((left, right) => left.label.compareTo(right.label));

    return List<TaskMaterialShortageEntity>.unmodifiable(shortages);
  }

  static _MaterialDemand? _demandFromRequirement({
    required String taskId,
    required TaskMaterialRequirementEntity requirement,
    required Map<String, MaterialStockItemEntity> stockById,
    required Map<String, String> stockIdByName,
  }) {
    final requiredQuantity = requirement.requiredQuantity;
    if (requiredQuantity <= 0) {
      return null;
    }

    final explicitStockId = requirement.stockItemId?.trim() ?? '';
    if (explicitStockId.isNotEmpty) {
      final stock = stockById[explicitStockId];
      return _MaterialDemand(
        key: 'stock:$explicitStockId',
        label: stock == null
            ? _labelFromRequirement(requirement)
            : _labelFromStock(stock),
        requiredQuantity: requiredQuantity,
        availableQuantity: stock?.quantity ?? 0,
        taskIds: <String>{taskId},
      );
    }

    final normalizedName = _normalize(requirement.name);
    if (normalizedName.isEmpty) {
      return null;
    }
    final stockId = stockIdByName[normalizedName];
    final stock = stockId == null ? null : stockById[stockId];
    return _MaterialDemand(
      key: stockId == null ? 'name:$normalizedName' : 'stock:$stockId',
      label: stock == null
          ? _labelFromRequirement(requirement)
          : _labelFromStock(stock),
      requiredQuantity: requiredQuantity,
      availableQuantity: stock?.quantity ?? 0,
      taskIds: <String>{taskId},
    );
  }

  static String _labelFromRequirement(
    TaskMaterialRequirementEntity requirement,
  ) {
    final name = requirement.name.trim();
    if (name.isNotEmpty) {
      return name;
    }
    final stockId = requirement.stockItemId?.trim() ?? '';
    return stockId.isEmpty ? requirement.id : stockId;
  }

  static String _labelFromStock(MaterialStockItemEntity stock) {
    final name = stock.name.trim();
    return name.isEmpty ? stock.id : name;
  }

  static String _normalize(String value) => value.trim().toLowerCase();
}

final class _MaterialDemand {
  const _MaterialDemand({
    required this.key,
    required this.label,
    required this.requiredQuantity,
    required this.availableQuantity,
    required this.taskIds,
  });

  final String key;

  final String label;

  final double requiredQuantity;

  final double availableQuantity;

  final Set<String> taskIds;

  _MaterialDemand merge(_MaterialDemand other) {
    return _MaterialDemand(
      key: key,
      label: label,
      requiredQuantity: requiredQuantity + other.requiredQuantity,
      availableQuantity: availableQuantity,
      taskIds: <String>{...taskIds, ...other.taskIds},
    );
  }
}
