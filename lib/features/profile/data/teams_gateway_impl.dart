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
  }) : _cloudRuClient = cloudRuClient,
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
  Future<Map<String, dynamic>?> loadTeamDetails(String teamId) async {
    try {
      _logger.log('teams_gateway_load_team_details_start: teamId=$teamId');

      final details = await _cloudRuClient.fetchTeamDetails(teamId);

      if (details == null) {
        _logger.log(
          'teams_gateway_load_team_details_not_found: teamId=$teamId',
        );
        return null;
      }

      _logger.log('teams_gateway_load_team_details_done: teamId=$teamId');
      return details;
    } on Exception catch (e) {
      _logger.log('teams_gateway_load_team_details_error: $e');
      return null;
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
  Future<void> deleteTeam({
    required String teamId,
    required String currentUserId,
  }) async {
    try {
      _logger.log(
        'teams_gateway_delete_team_start: teamId=$teamId userId=$currentUserId',
      );

      final success = await _cloudRuClient.deleteTeam(teamId);

      if (!success) {
        throw Exception('teams_delete_failed');
      }

      _logger.log('teams_gateway_delete_team_success: teamId=$teamId');
    } on Exception catch (e) {
      _logger.log('teams_gateway_delete_team_error: $e');
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
  Future<void> acceptInvitation({
    required String invitationToken,
  }) async {
    try {
      _logger.log(
        'teams_gateway_accept_invitation_start: token=$invitationToken',
      );

      final success = await _cloudRuClient.acceptTeamInvitation(
        invitationToken,
      );

      if (!success) {
        throw Exception('teams_accept_invitation_failed');
      }

      _logger.log('teams_gateway_accept_invitation_success');
    } on Exception catch (e) {
      _logger.log('teams_gateway_accept_invitation_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> rejectInvitation({
    required String invitationToken,
  }) async {
    try {
      _logger.log(
        'teams_gateway_reject_invitation_start: token=$invitationToken',
      );

      final success = await _cloudRuClient.rejectInvitation(
        invitationToken: invitationToken,
      );

      if (!success) {
        throw Exception('teams_reject_invitation_failed');
      }

      _logger.log('teams_gateway_reject_invitation_success');
    } on Exception catch (e) {
      _logger.log('teams_gateway_reject_invitation_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> revokeInvitation({
    required String teamId,
    required String invitationId,
  }) async {
    try {
      _logger.log(
        'teams_gateway_revoke_invitation_start: '
        'teamId=$teamId invitationId=$invitationId',
      );

      final success = await _cloudRuClient.revokeInvitation(
        teamId: teamId,
        invitationId: invitationId,
      );

      if (!success) {
        throw Exception('teams_revoke_invitation_failed');
      }

      _logger.log(
        'teams_gateway_revoke_invitation_success: '
        'teamId=$teamId invitationId=$invitationId',
      );
    } on Exception catch (e) {
      _logger.log('teams_gateway_revoke_invitation_error: $e');
      rethrow;
    }
  }

  @override
  Future<List<Map<String, dynamic>>> loadTeamInvitations(String teamId) async {
    try {
      _logger.log('teams_gateway_load_team_invitations_start: teamId=$teamId');

      final invitations = await _cloudRuClient.fetchTeamInvitations(teamId);

      if (invitations == null || invitations.isEmpty) {
        _logger.log(
          'teams_gateway_load_team_invitations_empty: teamId=$teamId',
        );
        return [];
      }

      final result = <Map<String, dynamic>>[];
      for (final inv in invitations) {
        try {
          result.add(inv as Map<String, dynamic>);
        } on Exception catch (e) {
          _logger.log('teams_gateway_parse_invitation_error: $e');
        }
      }

      _logger.log(
        'teams_gateway_load_team_invitations_done: count=${result.length}',
      );
      return result;
    } on Exception catch (e) {
      _logger.log('teams_gateway_load_team_invitations_error: $e');
      return [];
    }
  }

  @override
  Future<void> updateMemberRole({
    required String teamId,
    required String memberUserId,
    required List<String> roles,
  }) async {
    try {
      _logger.log(
        'teams_gateway_update_member_role_start: '
        'teamId=$teamId memberUserId=$memberUserId roles=$roles',
      );

      final success = await _cloudRuClient.updateMemberRole(
        teamId: teamId,
        memberUserId: memberUserId,
        roles: roles,
      );

      if (!success) {
        throw Exception('teams_update_member_role_failed');
      }

      _logger.log(
        'teams_gateway_update_member_role_success: '
        'teamId=$teamId memberUserId=$memberUserId',
      );
    } on Exception catch (e) {
      _logger.log('teams_gateway_update_member_role_error: $e');
      rethrow;
    }
  }

  @override
  Future<void> removeMember({
    required String teamId,
    required String memberUserId,
    required String currentUserId,
  }) async {
    try {
      _logger.log(
        'teams_gateway_remove_member_start: '
        'teamId=$teamId memberUserId=$memberUserId userId=$currentUserId',
      );

      final success = await _cloudRuClient.removeTeamMember(
        teamId: teamId,
        memberUserId: memberUserId,
      );

      if (!success) {
        throw Exception('teams_remove_member_failed');
      }

      _logger.log(
        'teams_gateway_remove_member_success: '
        'teamId=$teamId memberUserId=$memberUserId',
      );
    } on Exception catch (e) {
      _logger.log('teams_gateway_remove_member_error: $e');
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
