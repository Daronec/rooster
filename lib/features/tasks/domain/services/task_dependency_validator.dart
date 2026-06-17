import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Результат проверки DAG зависимостей задачи.
final class TaskDependencyValidationResult {
  /// Успешная валидация.
  const TaskDependencyValidationResult.valid()
      : isValid = true,
        error = null;

  /// Ошибка валидации.
  const TaskDependencyValidationResult.invalid(TaskDependencyValidationError this.error)
      : isValid = false;

  /// Успешно ли прошла проверка.
  final bool isValid;

  /// Код ошибки; null при успехе.
  final TaskDependencyValidationError? error;
}

/// Причины отказа при проверке зависимостей.
enum TaskDependencyValidationError {
  /// Задача ссылается сама на себя.
  selfDependency,

  /// В списке зависимостей (прямом или транзитивном) есть id, которого нет в [allTasks].
  unknownDependency,

  /// В графе есть цикл с учётом нового списка зависимостей для [taskId].
  cyclicDependencies,
}

/// Проверка зависимостей задачи: циклы, самоссылка, несуществующие id.
///
/// Для вершины [taskId] в обходе используется список [dependencyTaskIds]; для остальных
/// вершин — поле [TaskEntity.dependencyTaskIds] из [allTasks].
final class TaskDependencyValidator {
  TaskDependencyValidator._();

  /// Проверяет [dependencyTaskIds] для задачи [taskId].
  static TaskDependencyValidationResult validate({
    required String taskId,
    required List<String> dependencyTaskIds,
    required Map<String, TaskEntity> allTasks,
  }) {
    if (!allTasks.containsKey(taskId)) {
      return const TaskDependencyValidationResult.invalid(
        TaskDependencyValidationError.unknownDependency,
      );
    }
    if (dependencyTaskIds.contains(taskId)) {
      return const TaskDependencyValidationResult.invalid(
        TaskDependencyValidationError.selfDependency,
      );
    }
    for (final dependencyId in dependencyTaskIds) {
      if (!allTasks.containsKey(dependencyId)) {
        return const TaskDependencyValidationResult.invalid(
          TaskDependencyValidationError.unknownDependency,
        );
      }
    }

    final stack = <String>{};

    TaskDependencyValidationError? dfs(String nodeId) {
      if (!allTasks.containsKey(nodeId)) {
        return TaskDependencyValidationError.unknownDependency;
      }
      if (stack.contains(nodeId)) {
        return TaskDependencyValidationError.cyclicDependencies;
      }
      stack.add(nodeId);
      for (final nextId in _dependencyIdsFor(
        taskId: taskId,
        nodeId: nodeId,
        proposedDependencies: dependencyTaskIds,
        allTasks: allTasks,
      )) {
        if (!allTasks.containsKey(nextId)) {
          stack.remove(nodeId);
          return TaskDependencyValidationError.unknownDependency;
        }
        final nested = dfs(nextId);
        if (nested != null) {
          stack.remove(nodeId);
          return nested;
        }
      }
      stack.remove(nodeId);
      return null;
    }

    final cycleOrMissing = dfs(taskId);
    if (cycleOrMissing != null) {
      return TaskDependencyValidationResult.invalid(cycleOrMissing);
    }
    return const TaskDependencyValidationResult.valid();
  }

  /// Список исходящих рёбер «задача ждёт завершения» для вершины [nodeId].
  static List<String> _dependencyIdsFor({
    required String taskId,
    required String nodeId,
    required List<String> proposedDependencies,
    required Map<String, TaskEntity> allTasks,
  }) {
    if (nodeId == taskId) {
      return proposedDependencies;
    }
    final entity = allTasks[nodeId];
    return entity?.dependencyTaskIds ?? const [];
  }
}
