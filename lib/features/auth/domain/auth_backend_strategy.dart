/// Облачная авторизация: только Appwrite или отсутствие облачного входа.
enum AuthBackendStrategy {
  /// Appwrite Auth (Google / Apple / email по платформе).
  appwrite,

  /// Appwrite в `.env` не настроен: только локальные данные.
  offlineOnly,
}

/// Профиль хоста для аналитики и прочей инфраструктуры (не для выбора бэкенда авторизации).
final class HuaweiHmsHostProfile {
  /// Создаёт снимок.
  const HuaweiHmsHostProfile({
    required this.isAndroidHost,
    required this.isLikelyHuaweiOrHonorDevice,
  });

  /// Текущая платформа — Android (не web).
  final bool isAndroidHost;

  /// Производитель/бренд указывает на Huawei или Honor.
  final bool isLikelyHuaweiOrHonorDevice;
}

/// Возвращает [AuthBackendStrategy] по конфигурации Appwrite (без I/O).
AuthBackendStrategy resolveAuthBackendStrategy({
  required bool appwriteClientConfigured,
}) {
  if (appwriteClientConfigured) {
    return AuthBackendStrategy.appwrite;
  }
  return AuthBackendStrategy.offlineOnly;
}
