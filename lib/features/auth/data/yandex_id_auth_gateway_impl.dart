import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/app_dotenv.dart';
import 'package:rooster/features/auth/data/services/social_auth_service_types.dart';
import 'package:rooster/features/auth/data/services/social_sign_in_service.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_yandex_id_gateway.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:yandex_login_sdk/yandex_login_sdk.dart';

/// Implementation of [IYandexIdGateway], [IAuthGateway] and [SocialSignInService] for Yandex ID OAuth.
final class YandexIdAuthGatewayImpl
    with ChangeNotifier
    implements IYandexIdGateway, IAuthGateway, SocialSignInService {
  /// Creates the Yandex ID auth gateway.
  YandexIdAuthGatewayImpl({
    required ILogWriter logger,
    FlutterSecureStorage? secureStorage,
  }) : _logger = logger,
       _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    unawaited(_restoreSessionIfStored());
  }

  static String get clientId => AppDotenv.yandexIdClientId;

  final ILogWriter _logger;
  final FlutterSecureStorage _secureStorage;

  static const _yandexAccessTokenKey = 'oauth_yandex_access_token';
  static const _yandexUserIdKey = 'oauth_yandex_user_id';
  static const _yandexUserEmailKey = 'oauth_yandex_user_email';
  static const _yandexUserNameKey = 'oauth_yandex_user_name';

  final BehaviorSubject<AppAuthUserEntity?> _subject =
      BehaviorSubject<AppAuthUserEntity?>.seeded(null);

  AppAuthUserEntity? _currentUser;

  @override
  bool get isYandexIdAvailable => true;

  @override
  SocialAuthProvider get provider => SocialAuthProvider.yandex;

  @override
  Future<SocialAuthResult> signIn() async {
    _ensureConfigured(
      AppDotenv.yandexIdClientId.isNotEmpty,
      'YANDEX_ID_CLIENT_ID',
    );

    try {
      // Yandex SDK requires Activity context — delay until after frame is built
      // to ensure the plugin is attached to a FragmentActivity.
      final loginResult = await _deferSignIn();

      final user = await YandexLoginSdk.getUserInfo(token: loginResult.token);
      final email =
          user.defaultEmail ??
          (user.emails.isNotEmpty ? user.emails.first : null) ??
          '${user.login.isNotEmpty ? user.login : 'yandex-${user.id}'}@yandex.local';

      return SocialAuthResult(
        provider: provider,
        subject: user.id,
        email: email,
        phone: user.defaultPhone?.number,
        displayName:
            _nonEmpty(user.displayName ?? '') ??
            _nonEmpty(user.realName ?? '') ??
            _displayName([user.firstName, user.lastName]) ??
            _nonEmpty(user.login),
        accessToken: loginResult.token,
      );
    } on YandexAuthCancelledException {
      throw const SocialAuthCanceledException();
    }
  }

  /// Defer Yandex SDK signIn until the widget tree is attached to an Activity.
  /// Uses webOnly strategy to force Chrome Custom Tab (system Chrome has its own
  /// trust store, bypassing Russian CA certificate issues in the SDK's WebView).
  Future<YandexLoginResult> _deferSignIn() async {
    final completer = Completer<YandexLoginResult>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (completer.isCompleted) return;
      YandexLoginSdk.signIn(
        clientId: clientId,
        strategy: YandexLoginStrategy.webOnly,
      ).then(completer.complete).catchError(
        (Object error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        },
      );
    });

    return completer.future;
  }

  @override
  Stream<AppAuthUserEntity?> get authStateChanges => _subject.stream;

  @override
  AppAuthUserEntity? get currentUser => _currentUser;

  @override
  Future<void> signInWithYandexId() async {
    try {
      _logger.log('yandex_id_auth_start');
      debugPrint('YandexIdAuthGatewayImpl: starting Yandex ID OAuth...');

      // Defer Yandex SDK signIn until the widget tree is attached to an Activity.
      final loginResult = await _deferSignIn();

      debugPrint(
        'YandexIdAuthGatewayImpl: Yandex auth success, fetching user info...',
      );
      _logger.log('yandex_id_auth_tokens_obtained');

      final userInfo = await YandexLoginSdk.getUserInfo(
        token: loginResult.token,
      );

      final email = userInfo.defaultEmail?.isNotEmpty == true
          ? userInfo.defaultEmail
          : (userInfo.emails.isNotEmpty ? userInfo.emails.first : null);

      final firstName = userInfo.firstName?.isNotEmpty == true
          ? userInfo.firstName
          : null;
      final lastName = userInfo.lastName?.isNotEmpty == true
          ? userInfo.lastName
          : null;
      final displayName =
          [firstName, lastName].whereType<String>().join(' ').trim().isEmpty
          ? null
          : [firstName, lastName].whereType<String>().join(' ').trim();

      await _saveUserSession(
        userId: userInfo.id,
        email: email,
        displayName: displayName,
        accessToken: loginResult.token,
      );

      _logger.log('yandex_id_auth_complete user=${userInfo.id}');
      debugPrint('YandexIdAuthGatewayImpl: Yandex ID OAuth complete');
    } on YandexAuthCancelledException {
      debugPrint('YandexIdAuthGatewayImpl: Yandex auth cancelled');
      _logger.log('yandex_id_auth_cancelled');
      rethrow;
    } on YandexAuthInvalidTokenException {
      debugPrint('YandexIdAuthGatewayImpl: Yandex auth invalid token');
      _logger.log('yandex_id_auth_invalid_token');
      rethrow;
    } on Exception catch (e) {
      _logger.log('yandex_id_auth_error: $e');
      debugPrint('YandexIdAuthGatewayImpl: Yandex ID OAuth error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.log('yandex_id_auth_signout');
      await _clearStoredTokens();
      _subject.add(null);
      _currentUser = null;
      notifyListeners();
      debugPrint('YandexIdAuthGatewayImpl: signed out');
    } on Exception catch (e) {
      _logger.log('yandex_id_auth_signout_error: $e');
    }
  }

  @override
  void dispose() {
    _subject.close();
    super.dispose();
  }

  /// Restore session from stored tokens.
  Future<void> _restoreSessionIfStored() async {
    try {
      final userId = await _secureStorage.read(key: _yandexUserIdKey);
      if (userId == null || userId.isEmpty) {
        debugPrint('YandexIdAuthGatewayImpl: no stored Yandex user ID');
        return;
      }
      _logger.log('yandex_id_auth_session_restore_start');

      final email = await _secureStorage.read(key: _yandexUserEmailKey);
      final name = await _secureStorage.read(key: _yandexUserNameKey);

      _currentUser = AppAuthUserEntity(
        uid: userId,
        email: (email ?? '').isNotEmpty ? email : null,
        displayName: (name ?? '').isNotEmpty ? name : null,
        isAnonymous: false,
      );
      _subject.add(_currentUser);
      _logger.log('yandex_id_auth_session_restored_ok');
      debugPrint(
        'YandexIdAuthGatewayImpl: session restored for user $userId',
      );
    } on Exception catch (e) {
      _logger.log('yandex_id_auth_session_restore_error: $e');
      debugPrint('YandexIdAuthGatewayImpl: session restore error: $e');
    }
  }

  /// Save user data to secure storage after successful OAuth.
  Future<void> _saveUserSession({
    required String userId,
    required String? email,
    required String? displayName,
    required String accessToken,
  }) async {
    try {
      await _secureStorage.write(
        key: _yandexAccessTokenKey,
        value: accessToken,
      );
      await _secureStorage.write(key: _yandexUserIdKey, value: userId);
      await _secureStorage.write(
        key: _yandexUserEmailKey,
        value: email ?? '',
      );
      await _secureStorage.write(
        key: _yandexUserNameKey,
        value: displayName ?? '',
      );

      _currentUser = AppAuthUserEntity(
        uid: userId,
        email: (email ?? '').isNotEmpty ? email : null,
        displayName: (displayName ?? '').isNotEmpty ? displayName : null,
        isAnonymous: false,
      );
      _subject.add(_currentUser);
      _logger.log('yandex_id_auth_session_saved_ok user=$userId');
      debugPrint('YandexIdAuthGatewayImpl: session saved for user $userId');
    } on Exception catch (e) {
      _logger.log('yandex_id_auth_session_save_error: $e');
    }
  }

  /// Clear stored tokens on sign out.
  Future<void> _clearStoredTokens() async {
    try {
      await _secureStorage.delete(key: _yandexAccessTokenKey);
      await _secureStorage.delete(key: _yandexUserIdKey);
      await _secureStorage.delete(key: _yandexUserEmailKey);
      await _secureStorage.delete(key: _yandexUserNameKey);
    } on Exception catch (e) {
      _logger.log('yandex_id_auth_clear_tokens_error: $e');
    }
  }

  void _ensureConfigured(bool isConfigured, String key) {
    if (!isConfigured) {
      throw StateError(
        '$key is empty. Add it to the repository root .env.',
      );
    }
  }

  String? _nonEmpty(String? value) {
    final trimmed = value?.trim();
    return trimmed == null || trimmed.isEmpty ? null : trimmed;
  }

  String? _displayName(Iterable<String?> parts) {
    final value = parts
        .whereType<String>()
        .map((part) => part.trim())
        .where((part) => part.isNotEmpty)
        .join(' ');
    return value.isEmpty ? null : value;
  }
}
