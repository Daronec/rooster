import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:rooster/features/tasks/data/repositories/task_change_history_repository_impl.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_field_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';

void main() {
  const boxName = 'task_changes_test';
  late Directory tempDir;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('rooster_task_changes_hive_');
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    if (Hive.isBoxOpen(boxName)) {
      await Hive.box<dynamic>(boxName).close();
    }
    await Hive.deleteBoxFromDisk(boxName);
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test('схлопывает повторные автосохранения одного поля', () async {
    final box = await Hive.openBox<dynamic>(boxName);
    final repository = TaskChangeHistoryRepositoryImpl(changesBox: box);

    await repository.addChange(
      _change(
        id: 'first',
        changedAtMillis: 1000,
        fields: const <TaskChangeFieldEntity>[
          TaskChangeFieldEntity.description,
        ],
      ),
    );
    await repository.addChange(
      _change(
        id: 'second',
        changedAtMillis: 2000,
        fields: const <TaskChangeFieldEntity>[
          TaskChangeFieldEntity.description,
        ],
      ),
    );

    final changes = await repository.watchTaskChanges('task-1').first;

    expect(changes, hasLength(1));
    expect(changes.single.id, 'first');
    expect(changes.single.changedAtMillis, 2000);
  });

  test('не схлопывает разные наборы изменённых полей', () async {
    final box = await Hive.openBox<dynamic>(boxName);
    final repository = TaskChangeHistoryRepositoryImpl(changesBox: box);

    await repository.addChange(
      _change(
        id: 'description',
        changedAtMillis: 1000,
        fields: const <TaskChangeFieldEntity>[
          TaskChangeFieldEntity.description,
        ],
      ),
    );
    await repository.addChange(
      _change(
        id: 'title',
        changedAtMillis: 2000,
        fields: const <TaskChangeFieldEntity>[TaskChangeFieldEntity.title],
      ),
    );

    final changes = await repository.watchTaskChanges('task-1').first;

    expect(changes, hasLength(2));
  });

  test('не схлопывает одинаковые поля через другое изменение', () async {
    final box = await Hive.openBox<dynamic>(boxName);
    final repository = TaskChangeHistoryRepositoryImpl(changesBox: box);

    await repository.addChange(
      _change(
        id: 'description-1',
        changedAtMillis: 1000,
        fields: const <TaskChangeFieldEntity>[
          TaskChangeFieldEntity.description,
        ],
      ),
    );
    await repository.addChange(
      _change(
        id: 'title',
        changedAtMillis: 2000,
        fields: const <TaskChangeFieldEntity>[TaskChangeFieldEntity.title],
      ),
    );
    await repository.addChange(
      _change(
        id: 'description-2',
        changedAtMillis: 3000,
        fields: const <TaskChangeFieldEntity>[
          TaskChangeFieldEntity.description,
        ],
      ),
    );

    final changes = await repository.watchTaskChanges('task-1').first;

    expect(changes, hasLength(3));
  });
}

TaskChangeEntity _change({
  required String id,
  required int changedAtMillis,
  required List<TaskChangeFieldEntity> fields,
}) {
  return TaskChangeEntity(
    id: id,
    taskId: 'task-1',
    kind: TaskChangeKindEntity.updated,
    changedAtMillis: changedAtMillis,
    changedFields: fields,
    taskTitleSnapshot: 'Task',
    authorNameSnapshot: 'Дарон',
  );
}
