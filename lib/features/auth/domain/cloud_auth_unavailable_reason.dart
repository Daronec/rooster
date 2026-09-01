/// Почему запрошенный способ входа недоступен для текущего шлюза.
enum CloudAuthUnavailableReason {
  /// Нет настроенного облачного бэкенда или конфигурации.
  cloudNotConfigured,

  /// Вход в облако отключён политикой для данного устройства.
  cloudDisabledByDevicePolicy,

  /// Активна ветка HMS: Google / Apple / сброс пароля недоступны.
  hmsHostNonFirebaseProviders,

  /// Вход по email/паролю не реализован для текущего шлюза (офлайн).
  emailPasswordAuthNotSupported,

  /// Вход по SMS не поддерживается текущим шлюзом.
  phoneOtpAuthNotSupported,

  /// Вход через HUAWEI ID на ветке Firebase не используется (Huawei — отдельный бэкенд без Firebase).
  huaweiSignInUnavailableOnFirebaseBackend,

  /// Вход через HUAWEI ID в текущем режиме авторизации не предусмотрен (например Appwrite).
  huaweiSignInUnavailable,

  /// В `.env` не заданы параметры клиента Appwrite.
  appwriteNotConfigured,

  /// Анонимный вход в продукте не используется.
  anonymousAuthNotSupported,
}
