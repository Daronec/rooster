import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';

/// Реализация ITeamsGateway на базе cloud.ru (Yandex Serverless Functions).
class TeamsGatewayImpl implements ITeamsGateway {
  /// Создаёт реализацию.
  TeamsGatewayImpl({
    required CloudRuClient cloudRuClient,
    required ILogWriter logger,
  })  : _cloudRuClient = cloudRuClient,
        _logger = logger;

  final CloudRuClient _cloudRuClient;
  final ILogWriter _logger;

  @override
  String get teamInvitationReturnUrl => 'https://cloud.ru/teams/invite';

  @override
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(
    String userId,
  ) async {
    try {
      _logger.log('teams_gateway_load_teams_start: userId=$userId');

      final response = await _cloudRuClient.fetchTeamsForUser(userId);

      if (response == null || response.isEmpty) {
        _logger.log('teams_gateway_load_teams_empty: userId=$userId');
        return const [];
      }

      final teams = <ProfileTeamCardEntity>[];
      for (final teamJson in response) {
        try {
          final team = ProfileTeamCardEntity.fromJson(
            teamJson as Map<String, dynamic>,
          );
          teams.add(team);
        } on Exception catch (e) {
          _logger.log('teams_gateway_parse_team_error: $e');
        }
      }

      _logger.log('teams_gateway_load_teams_done: count=${teams.length}');
      return teams;
    } on Exception catch (e) {
      _logger.log('teams_gateway_load_teams_error: $e');
      return const [];
    }
  }

  @override
  Future<void> createTeam({
    required String name,
    required String currentUserId,
  }) async {
    try {
      _logger.log('teams_gateway_create_team_start: name=$name');

      final now = DateTime.now().millisecondsSinceEpoch;

      final teamData = {
        'teamName': name.trim(),
        'members': [
          {
            'userId': currentUserId,
            'displayName': '',
            'email': '',
            'roles': ['owner'],
            'confirm': true,
            'joinedAtMillis': now,
          },
        ],
        'currentUserMembershipId': _generateMembershipId(currentUserId),
        'currentUserIsOwner': true,
        'createdAtMillis': now,
      };

      final success = await _cloudRuClient.createTeam(teamData);

      if (!success) {
        throw Exception('teams_create_failed');
      }

      _logger.log('teams_gateway_create_team_success: name=$name');
    } on Exception catch (e) {
      _logger.log('teams_gateway_create_team_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  }) async {
    try {
      _logger.log(
        'teams_gateway_invite_email_start: teamId=$teamId email=$email',
      );

      final success = await _cloudRuClient.inviteToTeam(
        teamId: teamId,
        email: email,
        invitationReturnUrl: invitationReturnUrl,
      );

      if (!success) {
        throw Exception('teams_invite_failed');
      }

      _logger.log('teams_gateway_invite_email_success: teamId=$teamId');
    } on Exception catch (e) {
      _logger.log('teams_gateway_invite_email_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  }) async {
    try {
      _logger.log(
        'teams_gateway_leave_team_start: teamId=$teamId membershipId=$membershipId',
      );

      final success = await _cloudRuClient.leaveTeam(
        teamId: teamId,
        membershipId: membershipId,
      );

      if (!success) {
        throw Exception('teams_leave_failed');
      }

      _logger.log('teams_gateway_leave_team_success: teamId=$teamId');
    } on Exception catch (e) {
      _logger.log('teams_gateway_leave_team_error: $e');
      rethrow;
    }
  }

  /// Генерировать ID членства для пользователя.
  String _generateMembershipId(String userId) {
    return 'mem_${userId}_${DateTime.now().millisecondsSinceEpoch}';
  }
}
