import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_exception.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_reason.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/entities/app_phone_otp_challenge_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rxdart/rxdart.dart';

/// Облачная авторизация недоступна (нет настроенного Appwrite или режим только локально).
final class OfflineAuthGateway implements IAuthGateway {
  /// Создаёт шлюз.
  OfflineAuthGateway(
    this._logger, {
    this.unavailableReason = CloudAuthUnavailableReason.firebaseNotInitialized,
  });

  final ILogWriter _logger;

  /// Заданная причина недоступности входа.
  final CloudAuthUnavailableReason unavailableReason;

  final BehaviorSubject<AppAuthUserEntity?> _session =
      BehaviorSubject<AppAuthUserEntity?>.seeded(null);

  @override
  Stream<AppAuthUserEntity?> get authStateChanges => _session.stream;

  @override
  AppAuthUserEntity? get currentUser => _session.value;

  @override
  bool get isHuaweiSignInAvailable => false;

  @override
  bool get supportsEmailPasswordAuth => false;

  @override
  bool get supportsPhoneOtpAuth => false;

  @override
  Future<void> signInWithGoogle() async {
    _logger.log(
      'auth_blocked_${unavailableReason == CloudAuthUnavailableReason.firebaseNotInitialized ? 'no_firebase' : 'offline_only_policy'}',
    );
    throw CloudAuthUnavailableException(unavailableReason);
  }

  @override
  Future<void> signInWithApple() async {
    await signInWithGoogle();
  }

  @override
  Future<void> signInWithHuawei() async {
    await signInWithGoogle();
  }

  @override
  Future<void> signInAnonymously() async {
    await signInWithGoogle();
  }

  @override
  Future<void> signOut() async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await signInWithGoogle();
  }

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await signInWithGoogle();
  }

  @override
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {
    await signInWithGoogle();
  }

  @override
  Future<void> signUpWithEmailPasswordProfile({
    required String email,
    required String password,
    required String name,
    required String phoneE164,
  }) async {
    await signInWithGoogle();
  }

  @override
  Future<AppPhoneOtpChallengeEntity> startPhoneSignIn({
    required String phoneE164,
  }) async {
    _logger.log(
      'auth_blocked_${unavailableReason == CloudAuthUnavailableReason.firebaseNotInitialized ? 'no_firebase' : 'offline_only_policy'}',
    );
    throw CloudAuthUnavailableException(unavailableReason);
  }

  @override
  Future<void> completePhoneSignIn({
    required String userId,
    required String otpSecret,
  }) async {
    _logger.log(
      'auth_blocked_${unavailableReason == CloudAuthUnavailableReason.firebaseNotInitialized ? 'no_firebase' : 'offline_only_policy'}',
    );
    throw CloudAuthUnavailableException(unavailableReason);
  }
}
