import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';

/// Contract for Yandex ID authorization.
///
/// Used to launch OAuth flow (via native app or browser).
/// Auth result arrives through [IAuthGateway.authStateChanges].
abstract interface class IYandexIdGateway {
  Future<void> signInWithYandexId();
  bool get isYandexIdAvailable;
  AppAuthUserEntity? get currentUser;
  Stream<AppAuthUserEntity?> get authStateChanges;
  Future<void> signOut();
  void dispose();
}
