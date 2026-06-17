import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_status_entity.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_due_reminder_gateway.dart';
import 'package:rooster/features/tasks/domain/services/task_due_reminder_datetime_calculator.dart';
import 'package:rooster/integration/notifications/notification_strings_resolver.dart';
import 'package:rooster/integration/notifications/task_due_notification_datetime_formatter.dart';
import 'package:timezone/timezone.dart' as tz;

/// Локальные уведомления: напоминания задач по [TaskEntity.dueAt].
final class LocalNotificationsTaskDueReminderGateway
    implements ITaskDueReminderGateway {
  /// Создаёт шлюз.
  LocalNotificationsTaskDueReminderGateway({
    required FlutterLocalNotificationsPlugin plugin,
    required ILogWriter logger,
  }) : _plugin = plugin,
       _logger = logger;

  final FlutterLocalNotificationsPlugin _plugin;
  final ILogWriter _logger;

  static const String _channelId = 'task_due_reminders';
  static const String _channelName = 'Task reminders';
  static const String _channelDescription = 'Task due date reminders';

  static const String _payloadPrefix = 'taskId:';

  @override
  Future<void> upsertDueReminder(TaskEntity task) async {
    try {
      await _upsertDueReminder(task);
    } on Object catch (error, stackTrace) {
      if (!_isPluginNotInitializedError(error)) {
        _logger.exception(error, stackTrace);
      }
      if (kDebugMode) {
        _logger.log(
          'task_due_reminder_upsert_skip ${error.runtimeType}: $error',
        );
      }
    }
  }

  Future<void> _upsertDueReminder(TaskEntity task) async {
    final taskId = task.id.trim();
    if (taskId.isEmpty) {
      return;
    }

    if (task.status != TaskStatusEntity.pending) {
      await cancelDueReminder(taskId);
      return;
    }

    final dueAt = task.dueAt;
    if (dueAt == null) {
      await cancelDueReminder(taskId);
      return;
    }

    final scheduledAtLocal =
        TaskDueReminderDateTimeCalculator.calculateLocalDateTime(task);
    if (scheduledAtLocal == null) {
      await cancelDueReminder(taskId);
      return;
    }

    final scheduledTz = tz.TZDateTime.from(scheduledAtLocal, tz.local);
    final now = tz.TZDateTime.now(tz.local);
    if (!scheduledTz.isAfter(now.add(const Duration(seconds: 2)))) {
      await _showNow(task, dueAt: dueAt, taskId: taskId);
      return;
    }

    final id = _notificationIdFor(taskId);
    if (kDebugMode) {
      _logger.log(
        'task_due_reminder_upsert id=$id taskId=${_shortId(taskId)} '
        'dueAt=$dueAt preset=${task.reminderPreset.name} customAt=${task.customReminderAt} '
        'atLocal=$scheduledAtLocal tzAt=$scheduledTz',
      );
    }

    final title = task.title.trim().isEmpty
        ? await NotificationStringsResolver.translate(
            'notifications.taskDue.titleFallback',
          )
        : task.title.trim();
    final body = await NotificationStringsResolver.translate(
      'notifications.taskDue.body',
      params: <String, String>{
        'due':
            TaskDueNotificationDateTimeFormatter.formatDueForNotificationBody(
              dueAt,
            ),
      },
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledTz,
      _notificationDetails(),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '$_payloadPrefix$taskId',
    );
  }

  Future<void> _showNow(
    TaskEntity task, {
    required DateTime dueAt,
    required String taskId,
  }) async {
    final id = _notificationIdFor(taskId);
    final title = task.title.trim().isEmpty
        ? await NotificationStringsResolver.translate(
            'notifications.taskDue.titleFallback',
          )
        : task.title.trim();
    final body = await NotificationStringsResolver.translate(
      'notifications.taskDue.body',
      params: <String, String>{
        'due':
            TaskDueNotificationDateTimeFormatter.formatDueForNotificationBody(
              dueAt,
            ),
      },
    );
    if (kDebugMode) {
      _logger.log(
        'task_due_reminder_show_now id=$id taskId=${_shortId(taskId)}',
      );
    }
    await _plugin.show(
      id,
      title,
      body,
      _notificationDetails(),
      payload: '$_payloadPrefix$taskId',
    );
  }

  @override
  Future<void> cancelDueReminder(String taskId) async {
    try {
      final id = _notificationIdFor(taskId.trim());
      if (kDebugMode) {
        _logger.log(
          'task_due_reminder_cancel id=$id taskId=${_shortId(taskId)}',
        );
      }
      await _plugin.cancel(id);
    } on Object catch (error, stackTrace) {
      if (!_isPluginNotInitializedError(error)) {
        _logger.exception(error, stackTrace);
      }
      if (kDebugMode) {
        _logger.log(
          'task_due_reminder_cancel_skip ${error.runtimeType}: $error',
        );
      }
    }
  }

  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.high,
        priority: Priority.high,
      ),
      iOS: DarwinNotificationDetails(),
    );
  }

  static int _notificationIdFor(String taskId) {
    // Стабильный int в пределах 31-bit для Android.
    final hash = taskId.hashCode;
    return hash & 0x7fffffff;
  }

  static String _shortId(String value) {
    final trimmed = value.trim();
    if (trimmed.length <= 8) {
      return trimmed;
    }
    return trimmed.substring(0, 8);
  }

  static bool _isPluginNotInitializedError(Object error) {
    return error is StateError &&
        error.message.contains(
          'Flutter Local Notifications must be initialized',
        );
  }
}
