import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_vk_id_gateway.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Implementation of [IVkIdGateway] and [IAuthGateway] for VK ID OAuth.
///
/// Flow:
/// 1. User clicks "Sign in with VK ID"
/// 2. VK ID OAuth2 flow starts (native app or browser)
/// 3. Get authorization tokens
/// 4. Save tokens to secure storage
/// 5. Build user entity from VK profile data
/// 6. Emit user to authStateChanges stream
final class VkIdAuthGatewayImpl
    with ChangeNotifier
    implements IVkIdGateway, IAuthGateway {
  VkIdAuthGatewayImpl({
    required ILogWriter logger,
    FlutterSecureStorage? secureStorage,
  })  : _logger = logger,
        _secureStorage = secureStorage ?? const FlutterSecureStorage() {
    unawaited(_restoreSessionIfStored());
  }

  final ILogWriter _logger;
  final FlutterSecureStorage _secureStorage;

  static const _vkAccessTokenKey = 'oauth_vk_access_token';
  static const _vkIdTokenKey = 'oauth_vk_id_token';
  static const _vkUserIdKey = 'oauth_vk_user_id';
  static const _vkUserEmailKey = 'oauth_vk_user_email';
  static const _vkUserNameKey = 'oauth_vk_user_name';

  final BehaviorSubject<AppAuthUserEntity?> _subject =
      BehaviorSubject<AppAuthUserEntity?>.seeded(null);

  AppAuthUserEntity? _currentUser;

  @override
  bool get isVkIdAvailable => true;

  @override
  Stream<AppAuthUserEntity?> get authStateChanges => _subject.stream;

  @override
  AppAuthUserEntity? get currentUser => _currentUser;

  @override
  Future<void> signInWithVkId() async {
    try {
      _logger.log('vk_id_auth_start');
      debugPrint('VkIdAuthGatewayImpl: starting VK ID OAuth...');

      // TODO: Integrate with vkid_flutter_sdk for actual OAuth flow.
      // Example flow (requires vkid_flutter_sdk):
      //
      //   final vkid = await VKID.getInstance();
      //   final authData = await vkid.authorize(
      //     params: AuthParamsBuilder().build(),
      //     onAuth: (authData) => authData,
      //   );
      //
      // For now, simulate a successful sign-in with test data.
      // Replace this block with real SDK integration.

      await _simulateVkOAuthFlow();

      _logger.log('vk_id_auth_complete');
      debugPrint('VkIdAuthGatewayImpl: VK ID OAuth complete');
    } on Exception catch (e) {
      _logger.log('vk_id_auth_error: $e');
      debugPrint('VkIdAuthGatewayImpl: VK ID OAuth error: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      _logger.log('vk_id_auth_signout');
      await _clearStoredTokens();
      _subject.add(null);
      _currentUser = null;
      notifyListeners();
      debugPrint('VkIdAuthGatewayImpl: signed out');
    } on Exception catch (e) {
      _logger.log('vk_id_auth_signout_error: $e');
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
      final userId = await _secureStorage.read(key: _vkUserIdKey);
      if (userId == null || userId.isEmpty) {
        debugPrint('VkIdAuthGatewayImpl: no stored VK user ID');
        return;
      }
      _logger.log('vk_id_auth_session_restore_start');

      final email = await _secureStorage.read(key: _vkUserEmailKey);
      final name = await _secureStorage.read(key: _vkUserNameKey);

      _currentUser = AppAuthUserEntity(
        uid: userId,
        email: email.isNotEmpty ? email : null,
        displayName: name.isNotEmpty ? name : null,
        isAnonymous: false,
      );
      _subject.add(_currentUser);
      _logger.log('vk_id_auth_session_restored_ok');
      debugPrint('VkIdAuthGatewayImpl: session restored for user $userId');
    } on Exception catch (e) {
      _logger.log('vk_id_auth_session_restore_error: $e');
      debugPrint('VkIdAuthGatewayImpl: session restore error: $e');
    }
  }

  /// Save user data to secure storage after successful OAuth.
  Future<void> _saveUserSession({
    required String userId,
    required String? email,
    required String? displayName,
    required String accessToken,
    required String idToken,
  }) async {
    try {
      await _secureStorage.write(key: _vkAccessTokenKey, value: accessToken);
      await _secureStorage.write(key: _vkIdTokenKey, value: idToken);
      await _secureStorage.write(key: _vkUserIdKey, value: userId);
      await _secureStorage.write(
        key: _vkUserEmailKey,
        value: email ?? '',
      );
      await _secureStorage.write(
        key: _vkUserNameKey,
        value: displayName ?? '',
      );

      _currentUser = AppAuthUserEntity(
        uid: userId,
        email: email.isNotEmpty ? email : null,
        displayName: displayName.isNotEmpty ? displayName : null,
        isAnonymous: false,
      );
      _subject.add(_currentUser);
      _logger.log('vk_id_auth_session_saved_ok');
      debugPrint('VkIdAuthGatewayImpl: session saved for user $userId');
    } on Exception catch (e) {
      _logger.log('vk_id_auth_session_save_error: $e');
    }
  }

  /// Clear stored tokens on sign out.
  Future<void> _clearStoredTokens() async {
    try {
      await _secureStorage.delete(key: _vkAccessTokenKey);
      await _secureStorage.delete(key: _vkIdTokenKey);
      await _secureStorage.delete(key: _vkUserIdKey);
      await _secureStorage.delete(key: _vkUserEmailKey);
      await _secureStorage.delete(key: _vkUserNameKey);
    } on Exception catch (e) {
      _logger.log('vk_id_auth_clear_tokens_error: $e');
    }
  }

  /// Simulated OAuth flow — replace with real vkid_flutter_sdk integration.
  Future<void> _simulateVkOAuthFlow() async {
    // In production, this would call:
    //   final vkid = await VKID.getInstance();
    //   final authData = await vkid.authorize(...);
    //
    // For now, we simulate the result:
    await Future.delayed(const Duration(seconds: 1));

    // Simulated VK user data
    const mockUserId = 'mock_vk_user_12345';
    const mockEmail = 'user@example.com';
    const mockName = 'Test User';
    const mockAccessToken = 'mock_vk_access_token';
    const mockIdToken = 'mock_vk_id_token';

    await _saveUserSession(
      userId: mockUserId,
      email: mockEmail,
      displayName: mockName,
      accessToken: mockAccessToken,
      idToken: mockIdToken,
    );
  }
}
