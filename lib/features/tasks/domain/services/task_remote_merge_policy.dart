import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';

/// Правило «кто новее» при входящей синхронизации с Appwrite (LWW + ревизия).
///
/// Используется репозиториями при входящем merge задач и списков.
abstract final class TaskRemoteMergePolicy {
  /// Возвращает `true`, если удалённая задача должна заменить локальную запись в Hive.
  static bool remoteTaskWins({
    required TaskEntity? local,
    required TaskEntity remote,
  }) {
    if (local == null) {
      return true;
    }
    if (remote.updatedAtMillis > local.updatedAtMillis) {
      return true;
    }
    if (remote.updatedAtMillis < local.updatedAtMillis) {
      return false;
    }
    return remote.contentRevision >= local.contentRevision;
  }

  /// Возвращает `true`, если удалённый список должен заменить локальную запись.
  static bool remoteListWins({
    required TaskListEntity? local,
    required TaskListEntity remote,
  }) {
    if (local == null) {
      return true;
    }
    if (remote.updatedAtMillis > local.updatedAtMillis) {
      return true;
    }
    if (remote.updatedAtMillis < local.updatedAtMillis) {
      return false;
    }
    return remote.contentRevision >= local.contentRevision;
  }
}
