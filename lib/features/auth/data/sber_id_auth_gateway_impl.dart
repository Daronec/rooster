import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/features/auth/domain/entities/sber_id_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';
import 'package:rooster/integration/appwrite/i_appwrite_session_storage.dart';

/// [ISberIdGateway] через Appwrite OAuth2 Custom Provider (Sber ID).
final class SberIdAuthGatewayImpl implements ISberIdGateway {
  /// Создаёт шлюз.
  SberIdAuthGatewayImpl({
    required Client client,
    required Account account,
    required AppwriteEnvConfig envConfig,
    required IAppwriteSessionStorage sessionStorage,
    required ILogWriter logger,
  }) : _client = client,
       _account = account,
       _envConfig = envConfig,
       _sessionStorage = sessionStorage,
       _logger = logger;

  final Client _client;
  final Account _account;
  final AppwriteEnvConfig _envConfig;
  final IAppwriteSessionStorage _sessionStorage;
  final ILogWriter _logger;

  @override
  bool get isSberIdAvailable => true;

  @override
  Future<SberIdUserEntity?> signInWithSberId() async {
    try {
      // Используем кастомный OAuth2 провайдер для Sber ID.
      // В Appwrite Console должен быть настроен Custom Provider с именем 'sberid'.
      await _account.createOAuth2Session(
        provider: appwrite_enums.OAuthProvider.auth0,
        success: _envConfig.oauthSuccessUrl,
        failure: _envConfig.oauthFailureUrl,
        scopes: ['openid profile email'],
      );

      // Получаем данные пользователя после успешной авторизации.
      final user = await _account.get();

      // Сохраняем сессию.
      await _tryPersistCurrentSessionSecret();

      _logger.log('sber_id_auth_ok');

      return SberIdUserEntity(
        id: user.$id,
        email: user.email.trim().isEmpty ? null : user.email.trim(),
        displayName: user.name.trim().isEmpty ? null : user.name.trim(),
        phone: user.phone.trim().isEmpty ? null : user.phone.trim(),
      );
    } on AppwriteException catch (error) {
      if (kDebugMode) {
        _logger.log('sber_id_auth_failed ${error.message}');
      }
      return null;
    } on Object catch (error) {
      if (kDebugMode) {
        _logger.log('sber_id_auth_failed $error');
      }
      return null;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSessions();
    } on AppwriteException catch (error) {
      _logger.log('sber_id_delete_sessions ${error.message}');
    }
    _client.setSession('');
    await _sessionStorage.clear();
    _logger.log('sber_id_sign_out_ok');
  }

  Future<void> _tryPersistCurrentSessionSecret() async {
    try {
      final currentSession = await _account.getSession(sessionId: 'current');
      final secret = currentSession.secret.trim();
      if (secret.isEmpty) {
        return;
      }
      _client.setSession(secret);
      await _sessionStorage.writeSessionSecret(secret);
    } on AppwriteException catch (error) {
      if (kDebugMode) {
        _logger.log('sber_id_session_secret_skip ${error.message}');
      }
    }
  }
}
