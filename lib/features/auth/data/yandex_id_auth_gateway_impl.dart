import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_yandex_id_gateway.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Implementation of [IYandexIdGateway] and [IAuthGateway] for Yandex ID OAuth.
///
/// Flow:
/// 1. User clicks "Sign in with Yandex ID"
/// 2. Yandex ID OAuth2 flow starts (native app or browser)
/// 3. Get authorization tokens
/// 4. Save tokens to secure storage
/// 5. Fetch user profile from Yandex API
/// 6. Emit user to authStateChanges stream
final class YandexIdAuthGatewayImpl
    with ChangeNotifier
    implements IYandexIdGateway, IAuthGateway {
  YandexIdAuthGatewayImpl({
    required ILogWriter logger,
    FlutterSecureStorage? secureStorage,
  })  : _logger = logger,
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    unawaited(_restoreSessionIfStored());
  }

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
  Stream<AppAuthUserEntity?> get authStateChanges => _subject.stream;

  @override
  AppAuthUserEntity? get currentUser => _currentUser;

  @override
  Future<void> signInWithYandexId() async {
    try {
      _logger.log('yandex_id_auth_start');
      debugPrint('YandexIdAuthGatewayImpl: starting Yandex ID OAuth...');

      // TODO: Integrate with yandex_login_sdk for actual OAuth flow.
      // Example flow (requires yandex_login_sdk):
      //
      //   final loginResult = await YandexLoginSdk.signIn(
      //     clientId: AppDotenv.yandexIdClientId,
      //   );
      //   final userInfo = await YandexLoginSdk.getUserInfo(
      //     token: loginResult.token,
      //   );
      //
      // For now, simulate a successful sign-in with test data.
      // Replace this block with real SDK integration.

      await _simulateYandexOAuthFlow();

      _logger.log('yandex_id_auth_complete');
      debugPrint('YandexIdAuthGatewayImpl: Yandex ID OAuth complete');
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
        email: email.isNotEmpty ? email : null,
        displayName: name.isNotEmpty ? name : null,
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
        email: email.isNotEmpty ? email : null,
        displayName: displayName.isNotEmpty ? displayName : null,
        isAnonymous: false,
      );
      _subject.add(_currentUser);
      _logger.log('yandex_id_auth_session_saved_ok');
      debugPrint(
        'YandexIdAuthGatewayImpl: session saved for user $userId',
      );
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

  /// Simulated OAuth flow — replace with real yandex_login_sdk integration.
  Future<void> _simulateYandexOAuthFlow() async {
    // In production, this would call:
    //   final loginResult = await YandexLoginSdk.signIn(
    //     clientId: AppDotenv.yandexIdClientId,
    //   );
    //   final userInfo = await YandexLoginSdk.getUserInfo(
    //     token: loginResult.token,
    //   );
    //
    // For now, we simulate the result:
    await Future.delayed(const Duration(seconds: 1));

    // Simulated Yandex user data
    const mockUserId = 'mock_yandex_user_67890';
    const mockEmail = 'user@example.com';
    const mockName = 'Test User';
    const mockAccessToken = 'mock_yandex_access_token';

    await _saveUserSession(
      userId: mockUserId,
      email: mockEmail,
      displayName: mockName,
      accessToken: mockAccessToken,
    );
  }
}
