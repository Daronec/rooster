/// Парсер deep link URI → данные для навигации.
final class DeepLinkRouteParser {
  DeepLinkRouteParser._();

  /// Поддерживаемые форматы:
  /// - `rooster://task/<taskId>`
  /// - `rooster://task?taskId=<taskId>`
  /// - `https://roosterapp.online/task/<taskId>`
  static String? tryParseTaskId(Uri uri) {
    final scheme = uri.scheme.trim().toLowerCase();
    if (scheme == 'rooster') {
      return _parseRoosterScheme(uri);
    }
    if (scheme == 'https') {
      return _parseHttps(uri);
    }
    return null;
  }

  static String? _parseRoosterScheme(Uri uri) {
    final host = uri.host.trim().toLowerCase();
    if (host != 'task') {
      return null;
    }

    final queryTaskId = (uri.queryParameters['taskId'] ?? '').trim();
    if (queryTaskId.isNotEmpty) {
      return queryTaskId;
    }

    final segments = uri.pathSegments;
    if (segments.isEmpty) {
      return null;
    }
    final taskId = segments.first.trim();
    return taskId.isEmpty ? null : taskId;
  }

  static String? _parseHttps(Uri uri) {
    final host = uri.host.trim().toLowerCase();
    if (host != 'roosterapp.online') {
      return null;
    }

    final segments = uri.pathSegments;
    if (segments.length < 2) {
      return null;
    }
    if (segments[0].trim().toLowerCase() != 'task') {
      return null;
    }
    final taskId = segments[1].trim();
    return taskId.isEmpty ? null : taskId;
  }
}
