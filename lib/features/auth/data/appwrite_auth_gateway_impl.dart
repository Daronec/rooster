import 'dart:async';

import 'package:appwrite/appwrite.dart';
import 'package:appwrite/enums.dart' as appwrite_enums;
import 'package:appwrite/models.dart' as aw_models;
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_exception.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_reason.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/entities/app_phone_otp_challenge_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/integration/appwrite/i_appwrite_session_storage.dart';
import 'package:rxdart/rxdart.dart';

/// [IAuthGateway] через Appwrite Auth (email/пароль, OAuth Google/Apple).
final class AppwriteAuthGatewayImpl implements IAuthGateway {
  /// Создаёт шлюз и пытается восстановить сессию из [IAppwriteSessionStorage].
  AppwriteAuthGatewayImpl({
    required Client client,
    required Account account,
    required AppwriteEnvConfig envConfig,
    required IAppwriteSessionStorage sessionStorage,
    required ILogWriter logger,
  }) : _client = client,
       _account = account,
       _envConfig = envConfig,
       _sessionStorage = sessionStorage,
       _logger = logger {
    _subject = BehaviorSubject<AppAuthUserEntity?>.seeded(null);
    unawaited(_restoreSessionIfStored());
  }

  final Client _client;
  final Account _account;
  final AppwriteEnvConfig _envConfig;
  final IAppwriteSessionStorage _sessionStorage;
  final ILogWriter _logger;

  late final BehaviorSubject<AppAuthUserEntity?> _subject;

  static AppAuthUserEntity _mapUser(aw_models.User user) {
    final email = user.email.trim();
    final phone = user.phone.trim();
    final displayName = user.name.trim();
    return AppAuthUserEntity(
      uid: user.$id,
      email: email.isEmpty ? null : email,
      displayName: displayName.isEmpty ? null : displayName,
      isAnonymous: email.isEmpty && phone.isEmpty,
    );
  }

  Future<void> _restoreSessionIfStored() async {
    try {
      final userFromCookie = await _account.get();
      _subject.add(_mapUser(userFromCookie));
      await _tryPersistCurrentSessionSecret();
      _logger.log('appwrite_auth_session_restored_ok');
      return;
    } on AppwriteException {
      // Нет активной сессии в cookie — пробуем секрет из secure storage.
    }
    try {
      final storedSecret = await _sessionStorage.readSessionSecret();
      if (storedSecret == null || storedSecret.isEmpty) {
        return;
      }
      _client.setSession(storedSecret);
      final user = await _account.get();
      _subject.add(_mapUser(user));
      _logger.log('appwrite_auth_session_restored_ok');
    } on AppwriteException catch (error) {
      await _sessionStorage.clear();
      _client.setSession('');
      if (kDebugMode) {
        _logger.log('appwrite_auth_session_restore_failed ${error.message}');
      }
    } on Object catch (error) {
      if (kDebugMode) {
        _logger.log('appwrite_auth_session_restore_failed $error');
      }
    }
  }

  Future<void> _tryPersistCurrentSessionSecret() async {
    try {
      final currentSession = await _account.getSession(sessionId: 'current');
      await _persistSessionSecret(currentSession);
    } on AppwriteException catch (error) {
      if (kDebugMode) {
        _logger.log('appwrite_auth_current_session_secret_skip ${error.message}');
      }
    }
  }

  Future<void> _persistSessionSecret(aw_models.Session session) async {
    final secret = session.secret.trim();
    if (secret.isEmpty) {
      return;
    }
    _client.setSession(secret);
    await _sessionStorage.writeSessionSecret(secret);
  }

  Future<void> _afterSessionCreated(aw_models.Session session) async {
    await _persistSessionSecret(session);
    final user = await _account.get();
    _subject.add(_mapUser(user));
  }

  @override
  Stream<AppAuthUserEntity?> get authStateChanges => _subject.stream;

  @override
  AppAuthUserEntity? get currentUser => _subject.value;

  @override
  bool get supportsEmailPasswordAuth => true;

  @override
  bool get supportsPhoneOtpAuth => false;

  @override
  bool get isHuaweiSignInAvailable => false;

  @override
  Future<void> signInWithGoogle() async {
    await _account.createOAuth2Session(
      provider: appwrite_enums.OAuthProvider.google,
      success: _envConfig.oauthSuccessUrl,
      failure: _envConfig.oauthFailureUrl,
    );
    final user = await _account.get();
    _subject.add(_mapUser(user));
    await _tryPersistCurrentSessionSecret();
    _logger.log('appwrite_auth_oauth_google_ok');
  }

  @override
  Future<void> signInWithApple() async {
    await _account.createOAuth2Session(
      provider: appwrite_enums.OAuthProvider.apple,
      success: _envConfig.oauthSuccessUrl,
      failure: _envConfig.oauthFailureUrl,
    );
    final user = await _account.get();
    _subject.add(_mapUser(user));
    await _tryPersistCurrentSessionSecret();
    _logger.log('appwrite_auth_oauth_apple_ok');
  }

  @override
  Future<void> signInWithHuawei() async {
    throw CloudAuthUnavailableException(
      CloudAuthUnavailableReason.huaweiSignInUnavailable,
    );
  }

  @override
  Future<void> signInAnonymously() async {
    throw CloudAuthUnavailableException(
      CloudAuthUnavailableReason.anonymousAuthNotSupported,
    );
  }

  @override
  Future<void> signOut() async {
    try {
      await _account.deleteSessions();
    } on AppwriteException catch (error) {
      _logger.log('appwrite_auth_delete_sessions ${error.message}');
    }
    _client.setSession('');
    await _sessionStorage.clear();
    _subject.add(null);
    _logger.log('appwrite_auth_sign_out_ok');
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    final trimmed = email.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(email, 'email', 'empty');
    }
    await _account.createRecovery(
      email: trimmed,
      url: _envConfig.passwordRecoveryRedirectUrl,
    );
    if (kDebugMode) {
      _logger.log('appwrite_auth_recovery_email_requested');
    }
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final trimmed = email.trim();
    final session = await _account.createEmailPasswordSession(
      email: trimmed,
      password: password,
    );
    await _afterSessionCreated(session);
    if (kDebugMode) {
      _logger.log('appwrite_auth_email_sign_in_ok');
    }
  }

  @override
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await signUpWithEmailPasswordProfile(
      email: email,
      password: password,
      name: '',
      phoneE164: '',
    );
  }

  @override
  Future<void> signUpWithEmailPasswordProfile({
    required String email,
    required String password,
    required String name,
    required String phoneE164,
  }) async {
    final emailTrimmed = email.trim();
    final nameTrimmed = name.trim();
    final phoneTrimmed = phoneE164.trim();
    if (nameTrimmed.length > 128) {
      throw ArgumentError.value(name, 'name', 'max length 128');
    }
    await _account.create(
      userId: ID.unique(),
      email: emailTrimmed,
      password: password,
      name: nameTrimmed.isEmpty ? null : nameTrimmed,
    );
    final session = await _account.createEmailPasswordSession(
      email: emailTrimmed,
      password: password,
    );
    await _afterSessionCreated(session);
    if (phoneTrimmed.isNotEmpty) {
      await _account.updatePhone(phone: phoneTrimmed, password: password);
      final user = await _account.get();
      _subject.add(_mapUser(user));
      await _tryPersistCurrentSessionSecret();
      _logger.log(
        'appwrite_auth_register_phone_updated phoneLen=${phoneTrimmed.length}',
      );
    }
    if (kDebugMode) {
      _logger.log('appwrite_auth_email_sign_up_ok');
    }
  }

  @override
  Future<AppPhoneOtpChallengeEntity> startPhoneSignIn({
    required String phoneE164,
  }) async {
    final trimmed = phoneE164.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(phoneE164, 'phoneE164', 'empty');
    }
    final token = await _account.createPhoneToken(
      userId: ID.unique(),
      phone: trimmed,
    );
    if (kDebugMode) {
      _logger.log('appwrite_auth_phone_token_requested');
    }
    return AppPhoneOtpChallengeEntity(userId: token.userId);
  }

  @override
  Future<void> completePhoneSignIn({
    required String userId,
    required String otpSecret,
  }) async {
    final session = await _account.createSession(
      userId: userId,
      secret: otpSecret.trim(),
    );
    await _afterSessionCreated(session);
    if (kDebugMode) {
      _logger.log('appwrite_auth_phone_sign_in_ok');
    }
  }
}
