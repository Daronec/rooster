import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/repositories/i_tasks_repository.dart';

/// {@template save_task_use_case.class}
/// Use Case для сохранения или обновления задачи.
///
/// Обеспечивает единую точку входа в слой доменной логики
/// для операций создания/обновления задач, соответствуя
/// принципам чистой архитектуры и предотвращая обход
/// use case слоя из презентационного слоя.
/// {@endtemplate}
final class SaveTaskUseCase {
  /// Создаёт use case.
  const SaveTaskUseCase({
    required ITasksRepository tasksRepository,
  }) : _tasksRepository = tasksRepository;

  final ITasksRepository _tasksRepository;

  /// Сохранить или обновить задачу.
  ///
  /// Инкапсулирует операцию [ITasksRepository.saveTask],
  /// предоставляя стандартный интерфейс для презентационного слоя.
  Future<void> execute({required TaskEntity task}) {
    return _tasksRepository.saveTask(task);
  }
}
