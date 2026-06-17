import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/data/mappers/task_entity_codec.dart';
import 'package:rooster/features/tasks/domain/entities/task_priority_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_sync_state_entity.dart';

void main() {
  group('TaskEntityCodec миграция (старые записи Hive)', () {
    test(
      'старая карта без полей решений → дефолты и schemaVersion при сериализации',
      () {
        final legacyMap = <String, dynamic>{
          'id': 't1',
          'listId': 'l1',
          'title': 'Legacy',
          'description': '',
          'dueAt': null,
          'isAllDay': false,
          'startAt': null,
          'endAt': null,
          'durationMinutes': null,
          'reminderOffsetMinutes': null,
          'reminderPreset': 'none',
          'customReminderAt': null,
          'priority': 'normal',
          'tags': <String>[],
          'recurrenceWeekdaysMask': 0,
          'recurrenceReminderMinutesFromMidnight': null,
          'imageLocalPath': null,
          'imageRemoteUrl': null,
          'status': 'pending',
          'contentRevision': 0,
          'updatedAtMillis': 42,
          'syncState': 'pendingSync',
        };

        final entity = TaskEntityCodec.fromMap(legacyMap);

        expect(entity.importance, 3);
        expect(entity.complexity, 3);
        expect(entity.estimatedCost, 0);
        expect(entity.materialRequirements, isEmpty);
        expect(entity.dependencyTaskIds, isEmpty);
        expect(entity.isPinned, isFalse);
        expect(entity.ownerUserId, isNull);
        expect(entity.executorUserId, isNull);
        expect(entity.observerUserId, isNull);

        final roundTrip = TaskEntityCodec.toMap(entity);
        expect(
          roundTrip['schemaVersion'],
          TaskEntityCodec.currentSchemaVersion,
        );
        expect(roundTrip['importance'], 3);
        expect(roundTrip['estimatedCost'], 0);
      },
    );

    test('полная карта v1 читается без потери полей', () {
      final full = <String, dynamic>{
        'schemaVersion': TaskEntityCodec.currentSchemaVersion,
        'id': 'x',
        'listId': 'lx',
        'title': 'T',
        'description': 'd',
        'dueAt': null,
        'isAllDay': false,
        'startAt': null,
        'endAt': null,
        'durationMinutes': null,
        'reminderOffsetMinutes': null,
        'reminderPreset': 'none',
        'customReminderAt': null,
        'priority': 'high',
        'tags': <String>['a'],
        'recurrenceWeekdaysMask': 0,
        'recurrenceReminderMinutesFromMidnight': null,
        'imageLocalPath': null,
        'imageRemoteUrl': null,
        'status': 'completed',
        'contentRevision': 2,
        'updatedAtMillis': 99,
        'syncState': 'synced',
        'importance': 5,
        'urgency': 1,
        'complexity': 4,
        'estimatedCost': 150.5,
        'materialRequirementIds': <String>['m1', 'm2'],
        'dependencyTaskIds': <String>['d1'],
      };

      final entity = TaskEntityCodec.fromMap(full);
      expect(entity.importance, 5);
      expect(entity.complexity, 4);
      expect(entity.estimatedCost, 150.5);
      expect(entity.materialRequirements.length, 2);
      expect(
        entity.materialRequirements.map((row) => row.stockItemId).toList(),
        ['m1', 'm2'],
      );
      expect(
        entity.materialRequirements.every(
          (row) =>
              row.requiredQuantity == 1 &&
              row.lineCost == 0 &&
              row.name == row.stockItemId,
        ),
        isTrue,
      );
      expect(entity.dependencyTaskIds, ['d1']);
      expect(entity.status, TaskStatusEntity.completed);
      expect(entity.priority, TaskPriorityEntity.high);
      expect(entity.syncState, TaskSyncStateEntity.synced);
    });

    test('старый participant читается как исполнитель', () {
      final legacyMap = <String, dynamic>{
        'id': 't1',
        'listId': 'l1',
        'participantUserId': 'executor-user',
        'participantTeamId': 'team-1',
        'title': 'Legacy',
        'updatedAtMillis': 42,
      };

      final entity = TaskEntityCodec.fromMap(legacyMap);

      expect(entity.executorUserId, 'executor-user');
      expect(entity.executorTeamId, 'team-1');
    });
  });
}
