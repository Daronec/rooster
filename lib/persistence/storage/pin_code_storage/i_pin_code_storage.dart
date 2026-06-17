/// Хранилище пин-кода для быстрого входа.
///
/// Хранит пин и флаг «пользователь отказался сохранять пин» в защищённом хранилище.
abstract interface class IPinCodeStorage {
  /// Прочитать сохранённый пин-код; null, если пин не задан.
  Future<String?> getPin();

  /// Сохранить пин-код.
  Future<void> savePin(String pin);

  /// Удалить сохранённый пин-код.
  Future<void> clearPin();

  /// Пользователь нажал «Пропустить» и отказался сохранять пин-код.
  Future<bool> getPinDeclined();

  /// Сохранить флаг отказа от сохранения пин-кода.
  Future<void> setPinDeclined(bool value);

  /// Включён ли запрос пин-кода при входе (если есть токен). По умолчанию true.
  Future<bool> getPinEnabled();

  /// Включить или выключить запрос пин-кода при входе.
  Future<void> setPinEnabled(bool value);
}
