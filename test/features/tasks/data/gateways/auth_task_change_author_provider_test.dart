import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/auth/domain/entities/app_phone_otp_challenge_entity.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/tasks/data/gateways/auth_task_change_author_provider.dart';

void main() {
  group('AuthTaskChangeAuthorProvider', () {
    test('возвращает displayName текущего пользователя', () {
      final provider = AuthTaskChangeAuthorProvider(
        authGateway: _FakeAuthGateway(
          currentUser: const AppAuthUserEntity(
            uid: 'user-1',
            isAnonymous: false,
            email: 'user@example.com',
            displayName: 'Дарон',
          ),
        ),
      );

      expect(provider.currentAuthorName, 'Дарон');
    });

    test('использует email, если имя пользователя не задано', () {
      final provider = AuthTaskChangeAuthorProvider(
        authGateway: _FakeAuthGateway(
          currentUser: const AppAuthUserEntity(
            uid: 'user-1',
            isAnonymous: false,
            email: 'user@example.com',
          ),
        ),
      );

      expect(provider.currentAuthorName, 'user@example.com');
    });
  });
}

final class _FakeAuthGateway implements IAuthGateway {
  _FakeAuthGateway({required AppAuthUserEntity? currentUser})
    : _currentUser = currentUser;

  final AppAuthUserEntity? _currentUser;

  @override
  Stream<AppAuthUserEntity?> get authStateChanges =>
      Stream<AppAuthUserEntity?>.value(_currentUser);

  @override
  AppAuthUserEntity? get currentUser => _currentUser;

  @override
  bool get isHuaweiSignInAvailable => false;

  @override
  bool get supportsEmailPasswordAuth => false;

  @override
  bool get supportsPhoneOtpAuth => false;

  @override
  Future<void> completePhoneSignIn({
    required String userId,
    required String otpSecret,
  }) async {}

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signInAnonymously() async {}

  @override
  Future<void> signInWithApple() async {}

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signInWithGoogle() async {}

  @override
  Future<void> signInWithHuawei() async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmailPassword({
    required String email,
    required String password,
  }) async {}

  @override
  Future<void> signUpWithEmailPasswordProfile({
    required String email,
    required String password,
    required String name,
    required String phoneE164,
  }) async {}

  @override
  Future<AppPhoneOtpChallengeEntity> startPhoneSignIn({
    required String phoneE164,
  }) async {
    return const AppPhoneOtpChallengeEntity(userId: 'user-1');
  }
}
