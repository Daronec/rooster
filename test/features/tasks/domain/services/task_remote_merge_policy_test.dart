import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/services/task_remote_merge_policy.dart';

void main() {
  group('TaskRemoteMergePolicy', () {
    test('remoteTaskWins when local is null', () {
      const remote = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 10,
      );
      expect(
        TaskRemoteMergePolicy.remoteTaskWins(local: null, remote: remote),
        isTrue,
      );
    });

    test('remoteTaskWins when remote updatedAtMillis is greater', () {
      const local = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 5,
        contentRevision: 2,
      );
      const remote = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 10,
        contentRevision: 1,
      );
      expect(
        TaskRemoteMergePolicy.remoteTaskWins(local: local, remote: remote),
        isTrue,
      );
    });

    test('remoteTaskWins when same millis and remote revision is greater', () {
      const local = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 10,
        contentRevision: 1,
      );
      const remote = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 10,
        contentRevision: 2,
      );
      expect(
        TaskRemoteMergePolicy.remoteTaskWins(local: local, remote: remote),
        isTrue,
      );
    });

    test('remoteTaskWins false when local is strictly newer', () {
      const local = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 20,
        contentRevision: 1,
      );
      const remote = TaskEntity(
        id: '1',
        listId: 'l',
        title: 't',
        updatedAtMillis: 10,
        contentRevision: 99,
      );
      expect(
        TaskRemoteMergePolicy.remoteTaskWins(local: local, remote: remote),
        isFalse,
      );
    });

    test('remoteListWins same millis prefers equal or higher revision', () {
      const local = TaskListEntity(
        id: '1',
        name: 'a',
        colorArgb: 1,
        updatedAtMillis: 5,
        contentRevision: 3,
      );
      const remote = TaskListEntity(
        id: '1',
        name: 'b',
        colorArgb: 2,
        updatedAtMillis: 5,
        contentRevision: 3,
      );
      expect(
        TaskRemoteMergePolicy.remoteListWins(local: local, remote: remote),
        isTrue,
      );
    });
  });
}
