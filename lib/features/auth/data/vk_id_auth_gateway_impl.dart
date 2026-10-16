import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:rxdart/rxdart.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_vk_id_gateway.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vkid_flutter_sdk/library_vkid.dart';

/// Implementation of [IVkIdGateway] and [IAuthGateway] for VK ID OAuth.
final class VkIdAuthGatewayImpl
    with ChangeNotifier
    implements IVkIdGateway, IAuthGateway {
  /// Creates the VK ID auth gateway.
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
    final completer = Completer<AuthData>();

    try {
      _logger.log('vk_id_auth_start');
      debugPrint('VkIdAuthGatewayImpl: starting VK ID OAuth...');

      final vkid = await VKID.getInstance();

      vkid.authorize(
        params: AuthParamsBuilder().build(),
        onAuth: (authData) {
          debugPrint(
            'VkIdAuthGatewayImpl: VK ID auth success user=${authData.userID}',
          );
          _logger.log('vk_id_auth_success user=${authData.userID}');
          if (!completer.isCompleted) {
            completer.complete(authData);
          }
        },
        onError: (error) {
          debugPrint('VkIdAuthGatewayImpl: VK ID auth error: $error');
          _logger.log('vk_id_auth_error: $error');
          if (!completer.isCompleted) {
            if (error is AuthCancelledError) {
              completer.completeError(const _VkAuthCancelledException());
            } else if (error is AuthOtherError) {
              completer.completeError(StateError(error.description));
            } else {
              completer.completeError(
                StateError('VK ID authorization failed: $error'),
              );
            }
          }
        },
      );

      final authData = await completer.future;
      await _handleVkAuthSuccess(authData);
    } on _VkAuthCancelledException {
      rethrow;
    } on StateError {
      rethrow;
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
      await _logoutFromVkId();
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
        email: (email ?? '').isNotEmpty ? email : null,
        displayName: (name ?? '').isNotEmpty ? name : null,
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

  /// Handle successful VK ID auth and save session.
  Future<void> _handleVkAuthSuccess(AuthData authData) async {
    final userId = authData.userID.toString();
    final userData = authData.userData;
    final email = userData.email.isNotEmpty ? userData.email : null;
    final firstName = userData.firstName.isNotEmpty ? userData.firstName : null;
    final lastName = userData.lastName.isNotEmpty ? userData.lastName : null;
    final displayName = [firstName, lastName]
            .where((n) => n != null && n.isNotEmpty)
            .cast<String>()
            .join(' ')
            .trim()
          .isEmpty
        ? null
        : [firstName, lastName]
            .where((n) => n != null && n.isNotEmpty)
            .cast<String>()
            .join(' ')
            .trim();

    await _saveUserSession(
      userId: userId,
      email: email,
      displayName: displayName,
      accessToken: authData.token,
      idToken: authData.idToken,
    );

    _logger.log('vk_id_auth_session_saved_ok user=$userId');
    debugPrint('VkIdAuthGatewayImpl: session saved for user $userId');
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
        email: (email ?? '').isNotEmpty ? email : null,
        displayName: (displayName ?? '').isNotEmpty ? displayName : null,
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

  /// Logout from VK ID.
  Future<void> _logoutFromVkId() async {
    try {
      final vkid = await VKID.getInstance();
      vkid.logout();
      debugPrint('VkIdAuthGatewayImpl: VK ID logout done');
    } on Exception catch (e) {
      _logger.log('vk_id_logout_error: $e');
    }
  }
}

/// Exception thrown when VK ID auth is cancelled by user.
final class _VkAuthCancelledException implements Exception {
  const _VkAuthCancelledException();

  @override
  String toString() => 'VK ID authorization cancelled by user';
}
