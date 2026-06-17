import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/data/mappers/task_change_entity_codec.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';

void main() {
  group('TaskChangeEntityCodec', () {
    test('сохраняет и читает имя автора изменения', () {
      const entity = TaskChangeEntity(
        id: 'change-1',
        taskId: 'task-1',
        kind: TaskChangeKindEntity.updated,
        changedAtMillis: 42,
        changedFields: <TaskChangeFieldEntity>[TaskChangeFieldEntity.title],
        taskTitleSnapshot: 'Task',
        authorNameSnapshot: 'Дарон',
      );

      final map = TaskChangeEntityCodec.toMap(entity);
      final restored = TaskChangeEntityCodec.fromMap(map);

      expect(map['authorNameSnapshot'], 'Дарон');
      expect(restored.authorNameSnapshot, 'Дарон');
    });

    test('для старых записей без автора возвращает пустую строку', () {
      final restored = TaskChangeEntityCodec.fromMap(<String, dynamic>{
        'id': 'legacy-change',
        'taskId': 'task-1',
        'kind': TaskChangeKindEntity.created.name,
        'changedAtMillis': 42,
        'changedFields': <String>[],
        'taskTitleSnapshot': 'Task',
      });

      expect(restored.authorNameSnapshot, isEmpty);
    });
  });
}
