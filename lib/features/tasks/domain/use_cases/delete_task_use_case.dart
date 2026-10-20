import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// {@template delete_task_use_case.class}
/// Use Case для удаления задачи.
///
/// Обеспечивает единую точку входа в слой доменной логики
/// для операций удаления задач, соответствуя принципам
/// чистой архитектуры и предотвращая обход use case слоя
/// из презентационного слоя.
/// {@endtemplate}
final class DeleteTaskUseCase {
  /// Создаёт use case.
  const DeleteTaskUseCase({
    required ITasksRepository tasksRepository,
  }) : _tasksRepository = tasksRepository;

  final ITasksRepository _tasksRepository;

  /// Удалить задачу по [taskId].
  ///
  /// Инкапсулирует операцию [ITasksRepository.deleteTask],
  /// предоставляя стандартный интерфейс для презентационного слоя.
  Future<void> execute({required String taskId}) {
    return _tasksRepository.deleteTask(taskId);
  }
}
