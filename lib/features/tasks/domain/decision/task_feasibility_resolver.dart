import 'package:rooster/features/tasks/domain/decision/task_feasibility_resolution_entity.dart';
import 'package:rooster/features/tasks/domain/entities/budget_period_entity.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity_monetary_total.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_block_detail_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_missing_material_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';

/// Определяет [TaskFeasibilityStatusEntity] в порядке приоритетов из спецификации.
final class TaskFeasibilityResolver {
  const TaskFeasibilityResolver._();

  /// Приоритет: done → зависимости → деньги → материалы → ready.
  ///
  /// [budget]: null — денежная блокировка не применяется (нет активного периода).
  static TaskFeasibilityResolutionEntity resolve({
    required TaskEntity task,
    required Map<String, TaskEntity> tasksById,
    required List<MaterialStockItemEntity> stockItems,
    BudgetPeriodEntity? budget,
  }) {
    if (task.status == TaskStatusEntity.completed) {
      return const TaskFeasibilityResolutionEntity(
        status: TaskFeasibilityStatusEntity.done,
      );
    }

    final blockingTaskIds = _unresolvedDependencyIds(task, tasksById);
    if (blockingTaskIds.isNotEmpty) {
      return TaskFeasibilityResolutionEntity(
        status: TaskFeasibilityStatusEntity.blockedDependencies,
        detail: TaskFeasibilityBlockDetailEntity(
          status: TaskFeasibilityStatusEntity.blockedDependencies,
          blockingTaskIds: blockingTaskIds,
          blockingTaskTitles: _blockingTaskTitles(
            blockingTaskIds,
            tasksById,
          ),
        ),
      );
    }

    if (budget != null) {
      final remaining = budget.remaining;
      final budgeted = TaskEntityMonetaryTotal.budgetedAmount(task);
      if (budgeted > remaining) {
        final deficit = budgeted - remaining;
        final missingMaterials = _missingStockLinkedMaterials(
          task.materialRequirements,
          stockItems,
        );
        return TaskFeasibilityResolutionEntity(
          status: TaskFeasibilityStatusEntity.blockedMoney,
          detail: TaskFeasibilityBlockDetailEntity(
            status: TaskFeasibilityStatusEntity.blockedMoney,
            moneyDeficit: deficit,
            missingMaterialIds: missingMaterials
                .map((m) => m.label)
                .toList(growable: false),
            missingMaterials: missingMaterials,
          ),
        );
      }
    }

    final missingMaterials = _missingStockLinkedMaterials(
      task.materialRequirements,
      stockItems,
    );
    if (missingMaterials.isNotEmpty) {
      return TaskFeasibilityResolutionEntity(
        status: TaskFeasibilityStatusEntity.blockedMaterials,
        detail: TaskFeasibilityBlockDetailEntity(
          status: TaskFeasibilityStatusEntity.blockedMaterials,
          missingMaterialIds: missingMaterials
              .map((m) => m.label)
              .toList(growable: false),
          missingMaterials: missingMaterials,
        ),
      );
    }

    return const TaskFeasibilityResolutionEntity(
      status: TaskFeasibilityStatusEntity.ready,
    );
  }

  static List<String> _unresolvedDependencyIds(
    TaskEntity task,
    Map<String, TaskEntity> tasksById,
  ) {
    final blocking = <String>[];
    for (final dependencyId in task.dependencyTaskIds) {
      final predecessor = tasksById[dependencyId];
      final isDone = predecessor?.status == TaskStatusEntity.completed;
      if (!isDone) {
        blocking.add(dependencyId);
      }
    }
    return blocking;
  }

  static List<String> _blockingTaskTitles(
    List<String> blockingTaskIds,
    Map<String, TaskEntity> tasksById,
  ) {
    return blockingTaskIds
        .map((taskId) {
          final title = tasksById[taskId]?.title.trim() ?? '';
          return title.isEmpty ? taskId : title;
        })
        .toList(growable: false);
  }

  /// Строки с [TaskMaterialRequirementEntity.stockItemId]: на складе должно быть
  /// [MaterialStockItemEntity.quantity] >= [TaskMaterialRequirementEntity.requiredQuantity].
  static List<TaskMissingMaterialEntity> _missingStockLinkedMaterials(
    List<TaskMaterialRequirementEntity> requirements,
    List<MaterialStockItemEntity> stockItems,
  ) {
    final byId = <String, double>{
      for (final item in stockItems) item.id: item.quantity,
    };
    final byIdToLabel = <String, String>{
      for (final item in stockItems)
        item.id: (item.name.trim().isEmpty ? item.id : item.name.trim()),
    };
    final byNormalizedNameToId = <String, String>{
      for (final item in stockItems) _normalizeStockKey(item.name): item.id,
    };
    final missing = <TaskMissingMaterialEntity>[];
    for (final row in requirements) {
      final resolvedStockId = _resolveStockId(row, byNormalizedNameToId);
      if (resolvedStockId == null) {
        final fallbackLabel = row.name.trim();
        if (fallbackLabel.isNotEmpty) {
          missing.add(
            TaskMissingMaterialEntity(
              label: fallbackLabel,
              missingQuantity: row.requiredQuantity,
            ),
          );
        }
        continue;
      }
      final quantity = byId[resolvedStockId];
      if (quantity == null || quantity < row.requiredQuantity) {
        final label = byIdToLabel[resolvedStockId] ?? resolvedStockId;
        final available = quantity ?? 0;
        final deficit = (row.requiredQuantity - available).clamp(
          0.0,
          double.infinity,
        );
        missing.add(
          TaskMissingMaterialEntity(
            label: label,
            missingQuantity: deficit,
          ),
        );
      }
    }
    return missing;
  }

  static String _normalizeStockKey(String value) {
    return value.trim().toLowerCase();
  }

  static String? _resolveStockId(
    TaskMaterialRequirementEntity requirement,
    Map<String, String> byNormalizedNameToId,
  ) {
    final stockId = requirement.stockItemId;
    if (stockId != null && stockId.trim().isNotEmpty) {
      return stockId.trim();
    }
    final nameKey = _normalizeStockKey(requirement.name);
    if (nameKey.isEmpty) {
      return null;
    }
    return byNormalizedNameToId[nameKey];
  }
}
