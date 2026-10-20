import 'package:flutter_test/flutter_test.dart';
import 'package:rooster/features/profile/domain/entities/profile_entity.dart';
import 'package:rooster/features/profile/domain/entities/user_profile.dart';
import 'package:rooster/features/profile/domain/services/user_profile_service.dart';
import 'package:rooster/features/tasks/data/gateways/auth_task_change_author_provider.dart';

void main() {
  group('AuthTaskChangeAuthorProvider', () {
    test('возвращает displayName текущего пользователя', () {
      final service = _FakeUserProfileService(
        userProfile: const UserProfile(
          authUser: AppAuthUserEntity(
            uid: 'user-1',
            isAnonymous: false,
            email: 'user@example.com',
            displayName: 'Дарон',
          ),
        ),
      );

      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: service,
      );

      expect(provider.currentAuthorName, 'Дарон');
    });

    test('использует email, если имя пользователя не задано', () {
      final service = _FakeUserProfileService(
        userProfile: const UserProfile(
          authUser: AppAuthUserEntity(
            uid: 'user-1',
            isAnonymous: false,
            email: 'user@example.com',
          ),
        ),
      );

      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: service,
      );

      expect(provider.currentAuthorName, 'user@example.com');
    });

    test('возвращает null для неавторизованного пользователя', () {
      final service = _FakeUserProfileService(
        userProfile: UserProfile(
          authUser: const AppAuthUserEntity(uid: '', isAnonymous: false),
        ),
      );

      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: service,
      );

      expect(provider.currentAuthorName, isNull);
    });

    test('возвращает null когда профиль ещё не загружен', () {
      final service = _FakeUserProfileService(userProfile: null);

      final provider = AuthTaskChangeAuthorProvider(
        userProfileService: service,
      );

      expect(provider.currentAuthorName, isNull);
    });
  });
}

/// Composition-based fake для UserProfileService.
///
/// UserProfileService — final class, поэтому его нельзя реализовать через implements.
final class _FakeUserProfileService {
  _FakeUserProfileService({required UserProfile? userProfile})
      : _userProfile = userProfile;

  final UserProfile? _userProfile;

  UserProfile? get currentProfile => _userProfile;
}
