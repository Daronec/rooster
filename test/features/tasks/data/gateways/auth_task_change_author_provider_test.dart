import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
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
  Future<void> signOut() async {
    // coverage:ignore-line
    throw UnimplementedError();
  }


}
