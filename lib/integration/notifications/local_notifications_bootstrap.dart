import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Инициализация локальных уведомлений (без Firebase/FCM).
final class LocalNotificationsBootstrap {
  LocalNotificationsBootstrap._();

  /// Подготовить [FlutterLocalNotificationsPlugin] к работе.
  ///
  /// [onOpenTask] вызывается при клике по уведомлению задачи.
  static Future<void> initialize({
    required FlutterLocalNotificationsPlugin plugin,
    required ILogWriter logger,
    required Future<void> Function(String taskId) onOpenTask,
  }) async {
    tz.initializeTimeZones();
    try {
      final name = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(name));
      if (kDebugMode) {
        logger.log('local_notifications_timezone $name');
      }
    } on Object catch (error) {
      if (kDebugMode) {
        logger.log('local_notifications_timezone_fallback $error');
      }
      tz.setLocalLocation(tz.local);
    }

    try {
      await initializeDateFormatting('ru');
      await initializeDateFormatting('en');
    } on Object catch (error) {
      if (kDebugMode) {
        logger.log('local_notifications_date_symbols_skip $error');
      }
    }

    const settings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(),
    );
    await plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload == null || payload.isEmpty) {
          return;
        }
        const prefix = 'taskId:';
        if (!payload.startsWith(prefix)) {
          return;
        }
        final taskId = payload.substring(prefix.length).trim();
        if (taskId.isEmpty) {
          return;
        }
        onOpenTask(taskId).ignore();
      },
    );

    await _requestPermissions(plugin, logger);
    if (kDebugMode) {
      logger.log('local_notifications_initialized');
    }
  }

  static Future<void> _requestPermissions(
    FlutterLocalNotificationsPlugin plugin,
    ILogWriter logger,
  ) async {
    try {
      final android = plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await android?.requestNotificationsPermission();
      final exactAlarmsGranted = await android?.requestExactAlarmsPermission();
      if (exactAlarmsGranted == false) {
        logger.log('local_notifications_exact_alarms_not_granted');
      }
      await android?.createNotificationChannel(
        const AndroidNotificationChannel(
          'task_due_reminders',
          'Task reminders',
          description: 'Task due date reminders',
          importance: Importance.high,
        ),
      );

      final ios = plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);
    } on Object catch (error) {
      if (kDebugMode) {
        logger.log('local_notifications_permissions_skip $error');
      }
    }
  }
}
