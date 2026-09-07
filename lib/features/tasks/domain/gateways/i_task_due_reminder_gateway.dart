import 'package:rooster/features/tasks/domain/entities/task_entity.dart';

/// Планирование локальных напоминаний по сроку ([TaskEntity.dueAt]).
abstract interface class ITaskDueReminderGateway {
  /// Перепланировать локальное напоминание для задачи.
  ///
  /// Реализация должна быть идемпотентной: повторный вызов не должен
  /// создавать дубликаты уведомлений.
  Future<void> upsertDueReminder(TaskEntity task);

  /// Отменить локальное напоминание по id задачи.
  Future<void> cancelDueReminder(String taskId);
}


