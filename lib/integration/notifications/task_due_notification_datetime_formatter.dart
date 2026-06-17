import 'dart:ui' show PlatformDispatcher;

import 'package:intl/intl.dart';

/// Форматирование даты и времени срока задачи для текста локального уведомления.
///
/// Для шаблонов с названием месяца нужна инициализация локалей `intl`
/// ([initializeDateFormatting]); в приложении это делается в
/// [LocalNotificationsBootstrap.initialize].
final class TaskDueNotificationDateTimeFormatter {
  TaskDueNotificationDateTimeFormatter._();

  /// Код языка для форматирования: как у [NotificationStringsResolver] — `en` или `ru`.
  static String notificationLanguageCode() {
    final raw =
        PlatformDispatcher.instance.locale.languageCode.trim().toLowerCase();
    if (raw == 'en') {
      return 'en';
    }
    return 'ru';
  }

  /// [dueAt] показывается в локальном часовом поясе устройства.
  static String formatDueForNotificationBody(DateTime dueAt) {
    final local = dueAt.toLocal();
    try {
      if (notificationLanguageCode() == 'en') {
        return DateFormat('MMM d, y · h:mm a', 'en').format(local);
      }
      return DateFormat('d MMMM y, HH:mm', 'ru').format(local);
    } on Object catch (_) {
      return DateFormat('yyyy-MM-dd HH:mm').format(local);
    }
  }
}
