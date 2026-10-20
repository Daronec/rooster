import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';

/// Шлюз для работы с командами (cloud.ru).
abstract interface class ITeamsGateway {
  /// Загрузить команды пользователя с участниками.
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(String userId);

  /// Получить детали команды с участниками.
  Future<Map<String, dynamic>?> loadTeamDetails(String teamId);

  /// Создать новую команду.
  Future<void> createTeam({
    required String name,
    required String currentUserId,
  });

  /// Удалить команду.
  Future<void> deleteTeam({
    required String teamId,
    required String currentUserId,
  });

  /// Пригласить участника по email.
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  });

  /// Принять приглашение в команду по токену.
  Future<void> acceptInvitation({
    required String invitationToken,
  });

  /// Отклонить приглашение в команду по токену.
  Future<void> rejectInvitation({
    required String invitationToken,
  });

  /// Отозвать приглашение из команды.
  Future<void> revokeInvitation({
    required String teamId,
    required String invitationId,
  });

  /// Получить список активных приглашений в команде.
  Future<List<Map<String, dynamic>>> loadTeamInvitations(String teamId);

  /// Обновить роль участника в команде.
  Future<void> updateMemberRole({
    required String teamId,
    required String memberUserId,
    required List<String> roles,
  });

  /// Удалить участника из команды.
  Future<void> removeMember({
    required String teamId,
    required String memberUserId,
    required String currentUserId,
  });

  /// Покинуть команду.
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  });

  /// URL для письма приглашения в команду.
  String get teamInvitationReturnUrl;
}
