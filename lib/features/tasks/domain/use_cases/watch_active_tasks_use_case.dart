import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// {@template watch_active_tasks_use_case.class}
/// Use Case для наблюдения за активными задачами.
///
/// Выносит фильтрацию из презентационного слоя в домен:
/// - Исключает подзадачи (parentTaskId != null)
/// - Исключает архивные задачи (status == archived)
/// - Сортирует по updatedAtMillis (новые сверху)
///
/// Соответствует принципу Single Responsibility: фильтрация
/// бизнес-логики находится в domain слое, а не в presentation.
/// {@endtemplate}
final class WatchActiveTasksUseCase {
  /// Создаёт use case.
  const WatchActiveTasksUseCase({
    required ITasksRepository tasksRepository,
  }) : _tasksRepository = tasksRepository;

  final ITasksRepository _tasksRepository;

  /// Наблюдение за активными задачами.
  ///
  /// Возвращает поток задач, отфильтрованных по правилам:
  /// - Только задачи без родителя (top-level)
  /// - Только неархивные (status != archived)
  /// - Отсортированные по убыванию updatedAtMillis
  Stream<List<TaskEntity>> call() {
    return _tasksRepository.watchTasks().map(_filterAndSort);
  }

  /// Применяет правила фильтрации и сортировки.
  List<TaskEntity> _filterAndSort(List<TaskEntity> tasks) {
    return tasks
        .where(
          (task) =>
              task.parentTaskId == null || task.parentTaskId!.isEmpty,
        )
        .where((task) => task.status != TaskStatusEntity.archived)
        .toList(growable: false)
      ..sort((a, b) => b.updatedAtMillis.compareTo(a.updatedAtMillis));
  }
}
