import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';

/// Contract for Yandex ID authorization.
///
/// Used to launch OAuth flow (via native app or browser).
/// Auth result arrives through [IAuthGateway.authStateChanges].
abstract interface class IYandexIdGateway {
  /// Launch Yandex ID OAuth flow.
  Future<void> signInWithYandexId();

  /// Whether Yandex ID is available on this device.
  bool get isYandexIdAvailable;

  /// Current user if session is active, `null` otherwise.
  AppAuthUserEntity? get currentUser;

  /// Stream of user state changes.
  Stream<AppAuthUserEntity?> get authStateChanges;

  /// Sign out and clear stored tokens.
  Future<void> signOut();

  /// Dispose internal resources.
  void dispose();
}
