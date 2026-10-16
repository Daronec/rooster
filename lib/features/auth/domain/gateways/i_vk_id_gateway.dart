import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';

/// Contract for VK ID authorization.
///
/// Used to launch OAuth flow (via native app or browser).
/// Auth result arrives through [IAuthGateway.authStateChanges].
abstract interface class IVkIdGateway {
  /// Launch VK ID OAuth flow.
  Future<void> signInWithVkId();

  /// Whether VK ID is available on this device.
  bool get isVkIdAvailable;

  /// Current user if session is active, `null` otherwise.
  AppAuthUserEntity? get currentUser;

  /// Stream of user state changes.
  Stream<AppAuthUserEntity?> get authStateChanges;

  /// Sign out and clear stored tokens.
  Future<void> signOut();

  /// Dispose internal resources.
  void dispose();
}
