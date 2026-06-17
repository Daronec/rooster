import 'package:rooster/features/tasks/domain/entities/task_entity.dart' show TaskEntity;

/// Пресет напоминания относительно срока задачи или произвольная дата/время.
enum TaskReminderPresetEntity {
  /// Без напоминания.
  none,

  /// В день срока (локально, всегда в 09:00).
  onDueDay,

  /// За один календарный день (локально, всегда в 09:00).
  oneDayBefore,

  /// За два календарных дня (локально, всегда в 09:00).
  twoDaysBefore,

  /// За три календарных дня (локально, всегда в 09:00).
  threeDaysBefore,

  /// За одну неделю (наследие).
  oneWeekBefore,

  /// Пользователь задаёт дату и время напоминания ([TaskEntity.customReminderAt]).
  custom,
}
