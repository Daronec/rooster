import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';

/// Заглушка команд при отсутствии Appwrite.
final class NoopTeamsGatewayImpl implements ITeamsGateway {
  /// Создаёт заглушку.
  const NoopTeamsGatewayImpl();

  @override
  String get teamInvitationReturnUrl => '';

  @override
  Future<ProfileTeamCardEntity> createTeam({
    required String name,
    required String currentUserId,
  }) async {
    throw UnsupportedError('teams_unavailable_offline');
  }

  @override
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  }) async {
    throw UnsupportedError('teams_unavailable_offline');
  }

  @override
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(
    String currentUserId,
  ) async {
    return const <ProfileTeamCardEntity>[];
  }

  @override
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  }) async {
    throw UnsupportedError('teams_unavailable_offline');
  }
}
