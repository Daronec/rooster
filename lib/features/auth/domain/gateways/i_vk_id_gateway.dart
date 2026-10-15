import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';

/// Contract for VK ID authorization.
///
/// Used to launch OAuth flow (via native app or browser).
/// Auth result arrives through [IAuthGateway.authStateChanges].
abstract interface class IVkIdGateway {
  Future<void> signInWithVkId();
  bool get isVkIdAvailable;
  AppAuthUserEntity? get currentUser;
  Stream<AppAuthUserEntity?> get authStateChanges;
  Future<void> signOut();
  void dispose();
}
