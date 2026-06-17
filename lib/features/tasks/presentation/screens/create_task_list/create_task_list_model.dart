import 'package:elementary/elementary.dart';
import 'package:rooster/features/tasks/domain/entities/task_list_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_task_lists_repository.dart';

/// Модель экрана создания списка задач.
final class CreateTaskListScreenModel extends ElementaryModel {
  /// Создаёт модель.
  CreateTaskListScreenModel({
    required ITaskListsRepository repository,
    this.editingListId,
  }) : _repository = repository;

  final ITaskListsRepository _repository;

  /// Id редактируемого списка; `null` — режим создания.
  final String? editingListId;

  /// Загрузить список для формы редактирования.
  Future<TaskListEntity?> loadList(String listId) =>
      _repository.loadList(listId);

  /// Сохранить список локально и поставить в очередь синхронизации.
  Future<void> saveList(TaskListEntity list) => _repository.saveList(list);
}
