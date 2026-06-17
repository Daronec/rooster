import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rooster/integration/appwrite/i_appwrite_session_storage.dart';

/// [IAppwriteSessionStorage] на [FlutterSecureStorage].
final class AppwriteSessionSecureStorage implements IAppwriteSessionStorage {
  /// Создаёт хранилище.
  AppwriteSessionSecureStorage(this._secure);

  static const String _sessionSecretKey = 'rooster_appwrite_session_secret_v1';

  final FlutterSecureStorage _secure;

  @override
  Future<void> clear() async {
    await _secure.delete(key: _sessionSecretKey);
  }

  @override
  Future<String?> readSessionSecret() => _secure.read(key: _sessionSecretKey);

  @override
  Future<void> writeSessionSecret(String secret) async {
    await _secure.write(key: _sessionSecretKey, value: secret);
  }
}
