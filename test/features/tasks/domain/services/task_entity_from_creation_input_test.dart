import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/entities/task_creation_input_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_material_requirement_entity.dart';
import 'package:rooster/features/tasks/domain/services/task_entity_from_creation_input.dart';

void main() {
  group('TaskEntityFromCreationInput.mergeExisting', () {
    test('подставляет стоимость и материалы из формы', () {
      const existing = TaskEntity(
        id: 't1',
        listId: 'l1',
        title: 'Old',
        updatedAtMillis: 1,
        estimatedCost: 10,
        materialRequirements: <TaskMaterialRequirementEntity>[
          TaskMaterialRequirementEntity(
            id: 'row_m1',
            name: 'm1',
            requiredQuantity: 1,
            lineCost: 0,
            stockItemId: 'm1',
          ),
        ],
        dependencyTaskIds: <String>['d1'],
        contentRevision: 2,
      );

      const input = TaskCreationInputEntity(
        title: 'New title',
        description: '',
        listId: 'l1',
        estimatedCost: 500,
        materialRequirements: <TaskMaterialRequirementEntity>[
          TaskMaterialRequirementEntity(
            id: 'a',
            name: 'A',
            requiredQuantity: 2,
            lineCost: 10,
          ),
          TaskMaterialRequirementEntity(
            id: 'b',
            name: 'B',
            requiredQuantity: 1,
            lineCost: 0,
            stockItemId: 'b_stock',
          ),
        ],
      );

      final merged = TaskEntityFromCreationInput.mergeExisting(
        existing: existing,
        input: input,
        updatedAtMillis: 99,
      );

      expect(merged.estimatedCost, 500);
      expect(merged.materialRequirements.length, 2);
      expect(merged.materialRequirements.first.id, 'a');
      expect(merged.materialRequirements.first.name, 'A');
      expect(merged.dependencyTaskIds, const <String>['d1']);
      expect(merged.title, 'New title');
      expect(merged.contentRevision, 3);
    });
  });

  group('TaskEntityFromCreationInput.build', () {
    test('сохраняет стоимость и список материалов', () {
      const input = TaskCreationInputEntity(
        title: '  X  ',
        description: ' ',
        listId: 'l1',
        ownerUserId: 'owner-1',
        ownerNameSnapshot: 'Owner',
        executorUserId: 'executor-1',
        executorTeamId: 'team-1',
        observerUserId: 'observer-1',
        observerTeamId: 'team-2',
        estimatedCost: 42.5,
        materialRequirements: <TaskMaterialRequirementEntity>[
          TaskMaterialRequirementEntity(
            id: 'x_row',
            name: 'материал',
            requiredQuantity: 3,
            lineCost: 5,
          ),
        ],
      );

      final built = TaskEntityFromCreationInput.build(
        input: input,
        id: 'new-id',
        updatedAtMillis: 1,
      );

      expect(built.estimatedCost, 42.5);
      expect(built.materialRequirements.length, 1);
      expect(built.materialRequirements.single.id, 'x_row');
      expect(built.materialRequirements.single.requiredQuantity, 3);
      expect(built.title, 'X');
      expect(built.ownerUserId, 'owner-1');
      expect(built.ownerNameSnapshot, 'Owner');
      expect(built.executorUserId, 'executor-1');
      expect(built.observerUserId, 'observer-1');
    });

    test('отрицательную стоимость приводит к нулю', () {
      const input = TaskCreationInputEntity(
        title: 't',
        description: '',
        listId: 'l1',
        estimatedCost: -5,
      );

      final built = TaskEntityFromCreationInput.build(
        input: input,
        id: 'id',
        updatedAtMillis: 1,
      );

      expect(built.estimatedCost, 0);
    });
  });
}
