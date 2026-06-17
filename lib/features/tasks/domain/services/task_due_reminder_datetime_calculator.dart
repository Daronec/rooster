import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';

/// Вычисляет локальные дату/время напоминания по параметрам задачи.
final class TaskDueReminderDateTimeCalculator {
  TaskDueReminderDateTimeCalculator._();

  static const int _defaultHour = 9;

  /// Возвращает момент локального времени, когда нужно показать уведомление,
  /// или null, если напоминание отключено/невозможно.
  static DateTime? calculateLocalDateTime(TaskEntity task) {
    final dueAt = task.dueAt;
    if (dueAt == null) {
      return null;
    }
    final dueLocal = dueAt.toLocal();
    final dueDateAt0900 = DateTime(
      dueLocal.year,
      dueLocal.month,
      dueLocal.day,
      _defaultHour,
    );

    switch (task.reminderPreset) {
      case TaskReminderPresetEntity.none:
        return null;
      case TaskReminderPresetEntity.onDueDay:
        return dueDateAt0900;
      case TaskReminderPresetEntity.oneDayBefore:
        return dueDateAt0900.subtract(const Duration(days: 1));
      case TaskReminderPresetEntity.twoDaysBefore:
        return dueDateAt0900.subtract(const Duration(days: 2));
      case TaskReminderPresetEntity.threeDaysBefore:
        return dueDateAt0900.subtract(const Duration(days: 3));
      case TaskReminderPresetEntity.oneWeekBefore:
        return dueDateAt0900.subtract(const Duration(days: 7));
      case TaskReminderPresetEntity.custom:
        final custom = task.customReminderAt?.toLocal();
        if (custom == null) {
          return null;
        }
        return custom;
    }
  }
}


