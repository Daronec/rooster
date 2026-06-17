/// Сборка URI ссылки для открытия задачи в приложении.
///
/// Для шаринга используется HTTPS-ссылка (распознаётся мессенджерами), а
/// открытие в приложении обеспечивается App Links (Android) / Universal Links (iOS).
final class TaskDeepLinkUriBuilder {
  TaskDeepLinkUriBuilder._();

  /// URI для идентификатора задачи ([taskId] — непустая строка после trim).
  static Uri uriForTaskId(String taskId) {
    final trimmed = taskId.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(taskId, 'taskId', 'taskId must not be empty');
    }
    return Uri(
      scheme: 'https',
      host: 'roosterapp.online',
      path: '/task/$trimmed',
    );
  }
}
