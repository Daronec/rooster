/// Единственная стратегия авторизации: Sber ID через cloud.ru.
enum AuthBackendStrategy {
  /// Sber ID + cloud.ru (Yandex Serverless Functions).
  sberId,
}

/// Всегда возвращает [AuthBackendStrategy.sberId].
AuthBackendStrategy resolveAuthBackendStrategy({
  required bool appwriteClientConfigured,
}) {
  return AuthBackendStrategy.sberId;
}
