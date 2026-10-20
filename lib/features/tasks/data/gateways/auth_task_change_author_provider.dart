import 'package:rooster/features/profile/domain/services/user_profile_service.dart';
import 'package:rooster/features/tasks/domain/gateways/i_task_change_author_provider.dart';

/// Источник автора изменений задач на основе объединённого профиля пользователя.
final class AuthTaskChangeAuthorProvider implements ITaskChangeAuthorProvider {
  /// Создаёт источник.
  const AuthTaskChangeAuthorProvider({
    required UserProfileService userProfileService,
  }) : _userProfileService = userProfileService;

  final UserProfileService _userProfileService;

  @override
  String? get currentAuthorName {
    final profile = _userProfileService.currentProfile;
    if (profile == null || profile.authUser.uid.isEmpty) {
      return null;
    }
    return profile.displayName;
  }
}
