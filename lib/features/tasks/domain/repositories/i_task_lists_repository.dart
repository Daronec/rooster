import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';

/// Списки задач (имя + цвет), offline-first.
abstract interface class ITaskListsRepository {
  /// Поток списков.
  Stream<List<TaskListEntity>> watchLists();

  /// Один список по [listId] из локального хранилища; `null`, если нет записи.
  Future<TaskListEntity?> loadList(String listId);

  /// Сохранить список локально + sync.
  Future<void> saveList(TaskListEntity list);

  /// Удалить список.
  Future<void> deleteList(String listId);

  /// Входящая синхронизация: заменить локальный список, если снимок с облака новее; без постановки в sync queue.
  Future<void> mergeRemoteListIfNewer(TaskListEntity remote);
}
