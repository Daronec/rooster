import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:rooster/persistence/storage/pin_code_storage/i_pin_code_storage.dart';

/// Ключ хранения пин-кода в [FlutterSecureStorage].
const String _pinCodeKey = 'app_pin_code';

/// Ключ флага «пользователь отказался сохранять пин-код».
const String _pinDeclinedKey = 'app_pin_declined';

/// Ключ флага «включён запрос пин-кода при входе».
const String _pinEnabledKey = 'app_pin_enabled';

/// {@template pin_code_storage.class}
/// Реализация [IPinCodeStorage] через [FlutterSecureStorage].
/// {@endtemplate}
final class PinCodeStorageImpl implements IPinCodeStorage {

  /// {@macro pin_code_storage.class}
  const PinCodeStorageImpl(this._secureStorage);
  final FlutterSecureStorage _secureStorage;

  @override
  Future<String?> getPin() => _secureStorage.read(key: _pinCodeKey);

  @override
  Future<void> savePin(String pin) =>
      _secureStorage.write(key: _pinCodeKey, value: pin);

  @override
  Future<void> clearPin() => _secureStorage.delete(key: _pinCodeKey);

  @override
  Future<bool> getPinDeclined() async {
    final value = await _secureStorage.read(key: _pinDeclinedKey);
    return value == 'true';
  }

  @override
  Future<void> setPinDeclined(bool value) =>
      _secureStorage.write(key: _pinDeclinedKey, value: value.toString());

  @override
  Future<bool> getPinEnabled() async {
    final value = await _secureStorage.read(key: _pinEnabledKey);
    return value != 'false';
  }

  @override
  Future<void> setPinEnabled(bool value) =>
      _secureStorage.write(key: _pinEnabledKey, value: value.toString());
}
