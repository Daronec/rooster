import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/auth/domain/entities/app_auth_user_entity.dart';
import 'package:rooster/features/profile/domain/entities/user_profile.dart';
import 'package:rooster/features/profile/domain/services/user_profile_service.dart';
import 'package:rooster/features/tasks/data/gateways/auth_task_change_author_provider.dart';

void main() {
  group('AuthTaskChangeAuthorProvider', () {
    test('возвращает displayName текущего пользователя', () {
      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: _FakeUserProfileService(
          UserProfile(
            authUser: const AppAuthUserEntity(
              uid: 'user-1',
              isAnonymous: false,
              email: 'user@example.com',
              displayName: 'Дарон',
            ),
          ),
        ),
      );

      expect(provider.currentAuthorName, 'Дарон');
    });

    test('использует email, если имя пользователя не задано', () {
      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: _FakeUserProfileService(
          UserProfile(
            authUser: const AppAuthUserEntity(
              uid: 'user-1',
              isAnonymous: false,
              email: 'user@example.com',
            ),
          ),
        ),
      );

      expect(provider.currentAuthorName, 'user@example.com');
    });

    test('возвращает null для неавторизованного пользователя', () {
      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: _FakeUserProfileService(
          UserProfile(
            authUser: const AppAuthUserEntity(uid: '', isAnonymous: false),
          ),
        ),
      );

      expect(provider.currentAuthorName, isNull);
    });

    test('возвращает null когда профиль ещё не загружен', () {
      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: _FakeUserProfileService(null),
      );

      expect(provider.currentAuthorName, isNull);
    });
  });
}

/// Composition-based fake для IUserProfileService.
class _FakeUserProfileService implements IUserProfileService {
  _FakeUserProfileService(this._userProfile);

  final UserProfile? _userProfile;

  @override
  UserProfile? get currentProfile => _userProfile;

  @override
  AppAuthUserEntity? get currentAuthUser => _userProfile?.authUser;

  @override
  void init() {}

  @override
  void dispose() {}
}
