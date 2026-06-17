/// Персистентное хранение секрета сессии Appwrite (для холодного старта).
abstract interface class IAppwriteSessionStorage {
  /// Сохранить секрет сессии (из ответа [Session], если непустой).
  Future<void> writeSessionSecret(String secret);

  /// Прочитать секрет или `null`.
  Future<String?> readSessionSecret();

  /// Очистить.
  Future<void> clear();
}
