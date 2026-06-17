import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';

/// Доступ к командам Appwrite (список, создание, приглашение, выход).
abstract interface class ITeamsGateway {
  /// URL редиректа после приглашения в команду (платформы в консоли Appwrite).
  String get teamInvitationReturnUrl;

  /// Команды текущего пользователя с полным списком участников.
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(
    String currentUserId,
  );

  /// Создать команду; создатель получает роль владельца.
  Future<ProfileTeamCardEntity> createTeam({
    required String name,
    required String currentUserId,
  });

  /// Пригласить по email (письмо со ссылкой; [invitationReturnUrl] из платформ Appwrite).
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  });

  /// Покинуть команду или отозвать членство.
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  });
}
