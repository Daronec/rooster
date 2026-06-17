import 'package:appwrite/appwrite.dart';
import 'package:appwrite/models.dart' as aw_models;
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/config/appwrite_env_config.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_member_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';

/// [ITeamsGateway] через Appwrite Teams (тот же [Client], что и у сессии).
final class AppwriteTeamsGatewayImpl implements ITeamsGateway {
  /// Создаёт шлюз.
  AppwriteTeamsGatewayImpl({
    required Teams teams,
    required Account account,
    required AppwriteEnvConfig envConfig,
    required ILogWriter logger,
  }) : _teams = teams,
       _account = account,
       _envConfig = envConfig,
       _logger = logger;

  final Teams _teams;
  final Account _account;
  final AppwriteEnvConfig _envConfig;
  final ILogWriter _logger;

  @override
  String get teamInvitationReturnUrl => _envConfig.teamInviteReturnUrl;

  static ProfileTeamMemberEntity _mapMember(aw_models.Membership membership) {
    return ProfileTeamMemberEntity(
      membershipId: membership.$id,
      userId: membership.userId,
      displayName: membership.userName.trim(),
      email: membership.userEmail.trim(),
      roles: List<String>.from(membership.roles),
      confirm: membership.confirm,
    );
  }

  ProfileTeamCardEntity _mapTeamCard({
    required aw_models.Team team,
    required List<aw_models.Membership> memberships,
    required String currentUserId,
  }) {
    ProfileTeamMemberEntity? selfMembership;
    final mappedMembers = <ProfileTeamMemberEntity>[];
    for (final membership in memberships) {
      final entity = _mapMember(membership);
      mappedMembers.add(entity);
      if (membership.userId == currentUserId) {
        selfMembership = entity;
      }
    }
    final self = selfMembership;
    if (self == null) {
      if (memberships.length == 1) {
        final only = memberships.single;
        final isOwner = only.roles.contains('owner');
        if (isOwner) {
          if (kDebugMode) {
            _logger.log(
              'appwrite_teams_self_membership_fallback team=${_shortId(team.$id)} '
              'currentUser=${_shortId(currentUserId)} memberUser=${_shortId(only.userId)} '
              'roles=${only.roles}',
            );
          }
          final fallbackSelf = _mapMember(only);
          return ProfileTeamCardEntity(
            teamId: team.$id,
            teamName: team.name,
            members: mappedMembers,
            currentUserMembershipId: fallbackSelf.membershipId,
            currentUserRoles: List<String>.from(fallbackSelf.roles),
          );
        }
      }
      throw StateError(
        'appwrite_teams_missing_self_membership team=${team.$id} user=$currentUserId',
      );
    }
    return ProfileTeamCardEntity(
      teamId: team.$id,
      teamName: team.name,
      members: mappedMembers,
      currentUserMembershipId: self.membershipId,
      currentUserRoles: List<String>.from(self.roles),
    );
  }

  Future<List<aw_models.Membership>> _loadMembershipsWithRetry({
    required String teamId,
    required String currentUserId,
    int attempts = 5,
  }) async {
    var delay = const Duration(milliseconds: 120);
    for (var attempt = 1; attempt <= attempts; attempt++) {
      final result = await _teams.listMemberships(teamId: teamId);
      final memberships = result.memberships;
      var hasSelf = false;
      for (final member in memberships) {
        if (member.userId == currentUserId) {
          hasSelf = true;
          break;
        }
      }
      if (kDebugMode) {
        final membersShort = memberships
            .map(
              (member) => '${_shortId(member.userId)}:${member.confirm ? 'c' : 'p'}',
            )
            .toList(growable: false);
        String? firstMemberUserId;
        String? firstMemberUserEmail;
        List<String>? firstMemberRoles;
        if (memberships.isNotEmpty) {
          final first = memberships.first;
          firstMemberUserId = _shortId(first.userId);
          firstMemberUserEmail = first.userEmail.trim().isEmpty
              ? null
              : first.userEmail.trim();
          firstMemberRoles = List<String>.from(first.roles);
        }
        _logger.log(
          'appwrite_teams_memberships_try team=${_shortId(teamId)} '
          'attempt=$attempt count=${memberships.length} hasSelf=$hasSelf '
          'currentUser=${_shortId(currentUserId)} '
          'members=$membersShort '
          'firstUser=$firstMemberUserId firstEmail=$firstMemberUserEmail roles=$firstMemberRoles',
        );
      }
      if (hasSelf) {
        return memberships;
      }
      if (attempt < attempts) {
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
    return (await _teams.listMemberships(teamId: teamId)).memberships;
  }

  @override
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(
    String currentUserId,
  ) async {
    _logger.log(
      'appwrite_teams_list_start userId=${_shortId(currentUserId)} '
      'project=${_envConfig.projectId} endpoint=${_envConfig.publicEndpoint}',
    );
    try {
      try {
        final user = await _account.get();
        final matches = user.$id == currentUserId;
        _logger.log(
          'appwrite_teams_auth_probe ok matches=$matches '
          'sessionUser=${_shortId(user.$id)} requested=${_shortId(currentUserId)}',
        );
        try {
          final session = await _account.getSession(sessionId: 'current');
          _logger.log(
            'appwrite_teams_session_probe provider=${session.provider} '
            'providerUid=${session.providerUid} userId=${_shortId(session.userId)}',
          );
        } on Object catch (error) {
          _logger.log('appwrite_teams_session_probe_fail $error');
        }
      } on Object catch (error) {
        _logger.log('appwrite_teams_auth_probe_fail $error');
      }
      final teamList = await _listTeamsWithRetry();
      _logger.log(
        'appwrite_teams_list_ok count=${teamList.teams.length} total=${teamList.total}',
      );
      if (kDebugMode &&
          teamList.teams.isEmpty &&
          _envConfig.debugTeamsProbeTeamId.trim().isNotEmpty) {
        await _probeTeamVisibility(
          teamId: _envConfig.debugTeamsProbeTeamId.trim(),
          currentUserId: currentUserId,
        );
      }
      if (teamList.teams.isEmpty) {
        return const <ProfileTeamCardEntity>[];
      }
      final results = await Future.wait(
        teamList.teams.map((team) async {
          final memberships = await _loadMembershipsWithRetry(
            teamId: team.$id,
            currentUserId: currentUserId,
          );
          if (kDebugMode) {
            _logger.log(
              'appwrite_teams_memberships_ok team=${team.$id} '
              'count=${memberships.length}',
            );
          }
          try {
            return _mapTeamCard(
              team: team,
              memberships: memberships,
              currentUserId: currentUserId,
            );
          } on StateError catch (error) {
            _logger.log(
              '[AppwriteTeamsGatewayImpl] skipTeam $error',
            );
            return null;
          }
        }),
      );
      return results.whereType<ProfileTeamCardEntity>().toList(growable: false);
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_teams_list_fail code=${error.code} message=${error.message}',
      );
      rethrow;
    }
  }

  Future<aw_models.TeamList> _listTeamsWithRetry({int attempts = 5}) async {
    var delay = const Duration(milliseconds: 120);
    for (var attempt = 1; attempt <= attempts; attempt++) {
      final list = await _teams.list();
      if (kDebugMode) {
        _logger.log(
          'appwrite_teams_list_try attempt=$attempt count=${list.teams.length}',
        );
      }
      if (list.teams.isNotEmpty) {
        return list;
      }
      if (attempt < attempts) {
        await Future<void>.delayed(delay);
        delay *= 2;
      }
    }
    return _teams.list();
  }

  Future<void> _probeTeamVisibility({
    required String teamId,
    required String currentUserId,
  }) async {
    _logger.log(
      'appwrite_teams_probe_start team=${_shortId(teamId)} user=${_shortId(currentUserId)}',
    );
    try {
      final team = await _teams.get(teamId: teamId);
      _logger.log(
        'appwrite_teams_probe_get_ok team=${_shortId(team.$id)} nameLen=${team.name.length}',
      );
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_teams_probe_get_fail team=${_shortId(teamId)} code=${error.code} message=${error.message}',
      );
    } on Object catch (error) {
      _logger.log('appwrite_teams_probe_get_fail team=${_shortId(teamId)} $error');
    }

    try {
      final memberships = await _teams.listMemberships(teamId: teamId);
      var hasSelf = false;
      for (final member in memberships.memberships) {
        if (member.userId == currentUserId) {
          hasSelf = true;
          break;
        }
      }
      _logger.log(
        'appwrite_teams_probe_memberships_ok team=${_shortId(teamId)} '
        'count=${memberships.memberships.length} hasSelf=$hasSelf',
      );
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_teams_probe_memberships_fail team=${_shortId(teamId)} code=${error.code} message=${error.message}',
      );
    } on Object catch (error) {
      _logger.log(
        'appwrite_teams_probe_memberships_fail team=${_shortId(teamId)} $error',
      );
    }
  }

  @override
  Future<ProfileTeamCardEntity> createTeam({
    required String name,
    required String currentUserId,
  }) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      throw ArgumentError.value(name, 'name', 'empty');
    }
    final trimmedUserId = currentUserId.trim();
    if (trimmedUserId.isEmpty) {
      throw ArgumentError.value(currentUserId, 'currentUserId', 'empty');
    }
    final teamId = ID.unique();
    _logger.log('appwrite_teams_create_start teamId=${_shortId(teamId)}');
    try {
      final created = await _teams.create(teamId: teamId, name: trimmed);
      _logger.log('appwrite_teams_create_ok teamId=${created.$id}');
      final memberships = await _loadMembershipsWithRetry(
        teamId: created.$id,
        currentUserId: trimmedUserId,
      );
      return _mapTeamCard(
        team: created,
        memberships: memberships,
        currentUserId: trimmedUserId,
      );
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_teams_create_fail code=${error.code} message=${error.message}',
      );
      rethrow;
    }
  }

  @override
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  }) async {
    final trimmedEmail = email.trim();
    if (trimmedEmail.isEmpty) {
      throw ArgumentError.value(email, 'email', 'empty');
    }
    _logger.log(
      'appwrite_teams_invite_start team=${_shortId(teamId)} emailLen=${trimmedEmail.length}',
    );
    try {
      await _teams.createMembership(
        teamId: teamId,
        roles: const <String>['member'],
        email: trimmedEmail,
        url: invitationReturnUrl.isEmpty
            ? _envConfig.oauthSuccessUrl
            : invitationReturnUrl,
      );
      _logger.log('appwrite_teams_invite_ok team=${_shortId(teamId)}');
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_teams_invite_fail code=${error.code} message=${error.message}',
      );
      rethrow;
    }
  }

  @override
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  }) async {
    _logger.log(
      'appwrite_teams_leave_start team=${_shortId(teamId)} '
      'membership=${_shortId(membershipId)}',
    );
    try {
      await _teams.deleteMembership(
        teamId: teamId,
        membershipId: membershipId,
      );
      _logger.log('appwrite_teams_leave_ok team=${_shortId(teamId)}');
    } on AppwriteException catch (error) {
      _logger.log(
        'appwrite_teams_leave_fail code=${error.code} message=${error.message}',
      );
      rethrow;
    }
  }

  static String _shortId(String value) {
    if (value.length <= 8) {
      return value;
    }
    return value.substring(0, 8);
  }
}
