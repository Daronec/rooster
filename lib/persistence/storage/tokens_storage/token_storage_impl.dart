import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fresh_dio/fresh_dio.dart';

import 'package:rooster/persistence/storage/tokens_storage/auth_token_pair.dart';

/// Token storage.
typedef ITokenStorage = TokenStorage<AuthTokenPair>;

/// {@template tokens_storage.class}
/// Implementation [TokenStorage] via [FlutterSecureStorage].
/// {@endtemplate}
final class TokenStorageImpl implements ITokenStorage {

  /// {@macro tokens_storage.class}
  const TokenStorageImpl(this._secureStorage);
  final FlutterSecureStorage _secureStorage;

  @override
  Future<AuthTokenPair?> read() async {
    try {
      final tokenJson = await _secureStorage.read(
        key: TokensStorageKeys.authToken.keyName,
      );
      if (tokenJson == null) return null;
      return AuthTokenPair.fromJson(
        jsonDecode(tokenJson) as Map<String, dynamic>,
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> write(AuthTokenPair token) async {
    await _secureStorage.write(
      key: TokensStorageKeys.authToken.keyName,
      value: jsonEncode(token.toJson()),
    );
  }

  @override
  Future<void> delete() async {
    for (final key in TokensStorageKeys.values) {
      await _secureStorage.delete(key: key.keyName);
    }
  }
}

/// Keys for [TokenStorageImpl].
enum TokensStorageKeys {
  /// @nodoc.
  authToken('app_auth_token');

  /// Key name.
  final String keyName;

  const TokensStorageKeys(this.keyName);
}
