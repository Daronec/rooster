import 'package:hive_flutter/hive_flutter.dart';
import 'package:rooster/features/tasks/data/mappers/task_change_entity_codec.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_change_kind_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_change_history_repository.dart';

const _mergeWindow = Duration(minutes: 15);

/// Hive-репозиторий истории изменений задач.
final class TaskChangeHistoryRepositoryImpl
    implements ITaskChangeHistoryRepository, ITaskChangeHistoryWriter {
  /// Создаёт репозиторий.
  TaskChangeHistoryRepositoryImpl({required Box<dynamic> changesBox})
    : _box = changesBox;

  final Box<dynamic> _box;

  @override
  Stream<List<TaskChangeEntity>> watchTaskChanges(String taskId) async* {
    List<TaskChangeEntity> read() {
      final items = <TaskChangeEntity>[];
      for (final raw in _box.values) {
        if (raw is! Map) {
          continue;
        }
        final entity = TaskChangeEntityCodec.fromMap(
          Map<String, dynamic>.from(raw),
        );
        if (entity.taskId == taskId) {
          items.add(entity);
        }
      }
      items.sort((a, b) => b.changedAtMillis.compareTo(a.changedAtMillis));
      return items;
    }

    yield read();
    await for (final _ in _box.watch()) {
      yield read();
    }
  }

  /// Сохранить событие истории.
  @override
  Future<void> addChange(TaskChangeEntity change) async {
    final mergeCandidate = _findMergeCandidate(change);
    if (mergeCandidate != null) {
      final map = TaskChangeEntityCodec.toMap(change);
      map['id'] = mergeCandidate.id;
      await _box.put(mergeCandidate.id, map);

      return;
    }

    await _box.put(change.id, TaskChangeEntityCodec.toMap(change));
  }

  TaskChangeEntity? _findMergeCandidate(TaskChangeEntity change) {
    if (change.kind != TaskChangeKindEntity.updated) {
      return null;
    }
    final latest = _findLatestTaskChange(change.taskId);
    if (latest == null || !_canMerge(previous: latest, next: change)) {
      return null;
    }

    return latest;
  }

  TaskChangeEntity? _findLatestTaskChange(String taskId) {
    TaskChangeEntity? latest;
    for (final raw in _box.values) {
      if (raw is! Map) {
        continue;
      }
      final entity = TaskChangeEntityCodec.fromMap(
        Map<String, dynamic>.from(raw),
      );
      if (entity.taskId != taskId) {
        continue;
      }
      if (latest == null || entity.changedAtMillis > latest.changedAtMillis) {
        latest = entity;
      }
    }

    return latest;
  }

  bool _canMerge({
    required TaskChangeEntity previous,
    required TaskChangeEntity next,
  }) {
    if (previous.taskId != next.taskId ||
        previous.kind != next.kind ||
        previous.authorNameSnapshot != next.authorNameSnapshot) {
      return false;
    }
    if (next.changedAtMillis - previous.changedAtMillis >
        _mergeWindow.inMilliseconds) {
      return false;
    }
    if (previous.changedFields.length != next.changedFields.length) {
      return false;
    }
    for (var index = 0; index < previous.changedFields.length; index++) {
      if (previous.changedFields[index] != next.changedFields[index]) {
        return false;
      }
    }

    return true;
  }
}
