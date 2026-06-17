import 'package:rooster/features/tasks/domain/entities/task_change_entity.dart';

/// Доступ к истории изменений задач (локальное хранилище).
abstract interface class ITaskChangeHistoryRepository {
  /// Наблюдение за историей одной задачи (сортировка: новые сверху).
  Stream<List<TaskChangeEntity>> watchTaskChanges(String taskId);
}

/// Запись истории изменений задач.
abstract interface class ITaskChangeHistoryWriter {
  /// Добавить событие в историю.
  Future<void> addChange(TaskChangeEntity change);
}

