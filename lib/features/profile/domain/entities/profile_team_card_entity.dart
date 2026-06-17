import 'package:rooster/features/profile/domain/entities/profile_team_member_entity.dart';

/// Команда с участниками и контекстом текущего пользователя.
final class ProfileTeamCardEntity {
  /// Создаёт сущность.
  const ProfileTeamCardEntity({
    required this.teamId,
    required this.teamName,
    required this.members,
    required this.currentUserMembershipId,
    required this.currentUserRoles,
  });

  /// Идентификатор команды.
  final String teamId;

  /// Название команды.
  final String teamName;

  /// Участники.
  final List<ProfileTeamMemberEntity> members;

  /// Членство текущего пользователя (для выхода из команды).
  final String currentUserMembershipId;

  /// Роли текущего пользователя в команде.
  final List<String> currentUserRoles;

  /// Текущий пользователь — владелец команды (роль `owner`).
  bool get currentUserIsOwner {
    for (final role in currentUserRoles) {
      if (role.toLowerCase() == 'owner') {
        return true;
      }
    }
    return false;
  }
}
