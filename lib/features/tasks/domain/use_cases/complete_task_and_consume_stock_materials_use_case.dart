import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_material_stock_repository.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// Завершить задачу и списать материалы со склада, связанные через `stockItemId`.
///
/// Правило: при переходе задачи в [TaskStatusEntity.completed] уменьшаем
/// [MaterialStockItemEntity.quantity] по каждому `stockItemId` на сумму
/// [TaskEntity.materialRequirements.requiredQuantity]. Остаток не может стать
/// отрицательным (кламп к 0).
///
/// Обратная операция (возврат на pending) склад не пополняет.
final class CompleteTaskAndConsumeStockMaterialsUseCase {
  /// Создаёт use-case.
  const CompleteTaskAndConsumeStockMaterialsUseCase({
    required ITasksRepository tasksRepository,
    required IMaterialStockRepository materialStockRepository,
  }) : _tasksRepository = tasksRepository,
       _materialStockRepository = materialStockRepository;

  final ITasksRepository _tasksRepository;
  final IMaterialStockRepository _materialStockRepository;

  /// Выполнить операцию для [task] и целевого признака [completed].
  Future<void> execute({
    required TaskEntity task,
    required bool completed,
  }) async {
    final targetStatus =
        completed ? TaskStatusEntity.completed : TaskStatusEntity.pending;
    if (task.status == targetStatus) {
      return;
    }

    final updatedTask = task.copyWith(
      status: targetStatus,
      updatedAtMillis: DateTime.now().millisecondsSinceEpoch,
      syncState: TaskSyncStateEntity.pendingSync,
    );

    if (targetStatus != TaskStatusEntity.completed) {
      await _tasksRepository.saveTask(updatedTask);
      return;
    }

    final requiredByStockId = <String, double>{};
    for (final requirement in task.materialRequirements) {
      final stockId = requirement.stockItemId?.trim();
      if (stockId == null || stockId.isEmpty) {
        continue;
      }
      final qty = requirement.requiredQuantity;
      if (qty <= 0) {
        continue;
      }
      requiredByStockId[stockId] = (requiredByStockId[stockId] ?? 0) + qty;
    }

    if (requiredByStockId.isNotEmpty) {
      final currentItems = await _materialStockRepository.readAllItems();
      final updatedItems = _consume(currentItems, requiredByStockId);
      await _materialStockRepository.saveAllItems(updatedItems);
    }

    await _tasksRepository.saveTask(updatedTask);
  }

  List<MaterialStockItemEntity> _consume(
    List<MaterialStockItemEntity> items,
    Map<String, double> requiredByStockId,
  ) {
    return items
        .map((item) {
          final required = requiredByStockId[item.id];
          if (required == null) {
            return item;
          }
          final nextQty = (item.quantity - required).clamp(0.0, double.infinity);
          if (nextQty == item.quantity) {
            return item;
          }
          return MaterialStockItemEntity(
            id: item.id,
            name: item.name,
            quantity: nextQty,
            unit: item.unit,
          );
        })
        .toList(growable: false);
  }
}

// End of file.

// 
