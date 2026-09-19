/// Облачная авторизация: Cloud.ru (Sber ID) или отсутствие облачного входа.
enum AuthBackendStrategy {
  /// Cloud.ru + Sber ID OAuth.
  cloud,

  /// Cloud.ru не настроен: только локальные данные.
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

/// Возвращает [AuthBackendStrategy] по конфигурации Cloud.ru (без I/O).
AuthBackendStrategy resolveAuthBackendStrategy({
  required bool cloudConfigured,
}) {
  if (cloudConfigured) {
    return AuthBackendStrategy.cloud;
  }
  return AuthBackendStrategy.offlineOnly;
}
