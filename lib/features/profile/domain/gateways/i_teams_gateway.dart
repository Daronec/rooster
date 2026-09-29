import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';

/// Шлюз для работы с командами (cloud.ru).
abstract interface class ITeamsGateway {
  /// Загрузить команды пользователя с участниками.
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(String userId);

  /// Создать новую команду.
  Future<void> createTeam({
    required String name,
    required String currentUserId,
  });

  /// Пригласить участника по email.
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  });

  /// Покинуть команду.
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  });

  /// URL для письма приглашения в команду.
  String get teamInvitationReturnUrl;
}
