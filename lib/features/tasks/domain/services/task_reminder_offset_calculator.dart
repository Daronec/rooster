import 'package:rooster/features/tasks/domain/entities/task_entity.dart' show TaskEntity;
import 'package:rooster/features/tasks/domain/entities/task_reminder_preset_entity.dart';

/// Вычисление смещения напоминания в минутах до срока для совместимости с [TaskEntity.reminderOffsetMinutes].
final class TaskReminderOffsetCalculator {
  const TaskReminderOffsetCalculator._();

  /// Минуты «до срока»; для [TaskReminderPresetEntity.custom] — разница `due - custom`, не ниже 0.
  static int? minutesBeforeDue({
    required TaskReminderPresetEntity preset,
    DateTime? dueAt,
    DateTime? customReminderAt,
  }) {
    switch (preset) {
      case TaskReminderPresetEntity.none:
        return null;
      case TaskReminderPresetEntity.onDueDay:
        return 0;
      case TaskReminderPresetEntity.oneDayBefore:
        return 24 * 60;
      case TaskReminderPresetEntity.twoDaysBefore:
        return 2 * 24 * 60;
      case TaskReminderPresetEntity.threeDaysBefore:
        return 3 * 24 * 60;
      case TaskReminderPresetEntity.oneWeekBefore:
        return 7 * 24 * 60;
      case TaskReminderPresetEntity.custom:
        if (dueAt == null || customReminderAt == null) {
          return null;
        }
        final diff = dueAt.difference(customReminderAt).inMinutes;
        return diff < 0 ? 0 : diff;
    }
  }
}
