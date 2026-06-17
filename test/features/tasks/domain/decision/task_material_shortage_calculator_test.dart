import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/decision/task_material_shortage_calculator.dart';
import 'package:rooster/features/tasks/domain/entities/material_stock_item_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';

void main() {
  group('TaskMaterialShortageCalculator', () {
    test('находит материалы, которых нет в ресурсах', () {
      final shortages = TaskMaterialShortageCalculator.calculate(
        tasks: const <TaskEntity>[
          TaskEntity(
            id: 'task-1',
            listId: 'list',
            title: 'Task',
            updatedAtMillis: 1,
            materialRequirements: <TaskMaterialRequirementEntity>[
              TaskMaterialRequirementEntity(
                id: 'row-1',
                name: 'Кабель',
                requiredQuantity: 3,
                lineCost: 0,
              ),
            ],
          ),
        ],
        stockItems: const <MaterialStockItemEntity>[],
      );

      expect(shortages, hasLength(1));
      expect(shortages.single.label, 'Кабель');
      expect(shortages.single.missingQuantity, 3);
      expect(shortages.single.availableQuantity, 0);
    });

    test('агрегирует дефицит по нескольким активным задачам', () {
      final shortages = TaskMaterialShortageCalculator.calculate(
        tasks: const <TaskEntity>[
          TaskEntity(
            id: 'task-1',
            listId: 'list',
            title: 'Task 1',
            updatedAtMillis: 1,
            materialRequirements: <TaskMaterialRequirementEntity>[
              TaskMaterialRequirementEntity(
                id: 'row-1',
                name: 'Кабель',
                requiredQuantity: 3,
                lineCost: 0,
                stockItemId: 'stock-1',
              ),
            ],
          ),
          TaskEntity(
            id: 'task-2',
            listId: 'list',
            title: 'Task 2',
            updatedAtMillis: 2,
            materialRequirements: <TaskMaterialRequirementEntity>[
              TaskMaterialRequirementEntity(
                id: 'row-2',
                name: 'Кабель',
                requiredQuantity: 4,
                lineCost: 0,
                stockItemId: 'stock-1',
              ),
            ],
          ),
        ],
        stockItems: const <MaterialStockItemEntity>[
          MaterialStockItemEntity(id: 'stock-1', name: 'Кабель', quantity: 5),
        ],
      );

      expect(shortages, hasLength(1));
      expect(shortages.single.requiredQuantity, 7);
      expect(shortages.single.availableQuantity, 5);
      expect(shortages.single.missingQuantity, 2);
      expect(shortages.single.taskCount, 2);
    });

    test('игнорирует выполненные задачи', () {
      final shortages = TaskMaterialShortageCalculator.calculate(
        tasks: const <TaskEntity>[
          TaskEntity(
            id: 'task-1',
            listId: 'list',
            title: 'Done',
            updatedAtMillis: 1,
            status: TaskStatusEntity.completed,
            materialRequirements: <TaskMaterialRequirementEntity>[
              TaskMaterialRequirementEntity(
                id: 'row-1',
                name: 'Кабель',
                requiredQuantity: 3,
                lineCost: 0,
              ),
            ],
          ),
        ],
        stockItems: const <MaterialStockItemEntity>[],
      );

      expect(shortages, isEmpty);
    });
  });
}
