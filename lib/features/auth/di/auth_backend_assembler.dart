import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/data/vk_id_auth_gateway_impl.dart';
import 'package:rooster/features/auth/data/yandex_id_auth_gateway_impl.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_vk_id_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_yandex_id_gateway.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/profile/data/teams_gateway_impl.dart';
import 'package:rooster/features/profile/domain/entities/profile_team_card_entity.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Assembly result for VK ID / Yandex ID auth backends.
class AuthBackendAssemblyResult {
  /// Creates the assembly result.
  AuthBackendAssemblyResult({
    required this.authGateway,
    required this.vkIdGateway,
    required this.yandexIdGateway,
    required this.teamsGateway,
  });

  /// Primary auth gateway (VK ID by default).
  final IAuthGateway authGateway;

  /// VK ID gateway for direct access.
  final IVkIdGateway vkIdGateway;

  /// Yandex ID gateway for direct access.
  final IYandexIdGateway yandexIdGateway;

  /// Teams gateway for profile/teams operations.
  final ITeamsGateway teamsGateway;
}

/// Assembles auth backends for VK ID and Yandex ID.
///
/// Creates gateway instances and a teams gateway.
/// The primary [IAuthGateway] is the VK ID gateway.
Future<AuthBackendAssemblyResult> assembleAuthBackend({
  required SharedPreferences sharedPreferences,
  required FlutterSecureStorage secureStorage,
  required ILogWriter logger,
  required String serverlessEndpoint,
  required String storageEndpoint,
  required String tokenExchangeEndpoint,
}) async {
  final vkIdGateway = VkIdAuthGatewayImpl(
    logger: logger,
    secureStorage: secureStorage,
  );
  final yandexIdGateway = YandexIdAuthGatewayImpl(
    logger: logger,
    secureStorage: secureStorage,
  );

  // Teams gateway via Cloud.ru Serverless Functions
  final cloudRuClient = CloudRuClient(
    serverlessEndpoint: serverlessEndpoint,
    storageEndpoint: storageEndpoint,
    iamToken: null,
    logger: logger,
  );
  final teamsGateway = TeamsGatewayImpl(
    cloudRuClient: cloudRuClient,
    logger: logger,
  );

  return AuthBackendAssemblyResult(
    authGateway: vkIdGateway,
    vkIdGateway: vkIdGateway,
    yandexIdGateway: yandexIdGateway,
    teamsGateway: teamsGateway,
  );
}

/// Noop teams gateway — placeholder until real implementation is ready.
final class NoopTeamsGateway implements ITeamsGateway {
  /// Creates the noop teams gateway.
  const NoopTeamsGateway();

  @override
  Future<List<ProfileTeamCardEntity>> loadTeamsWithMembers(
    String userId,
  ) async => [];

  @override
  Future<Map<String, dynamic>?> loadTeamDetails(String teamId) async => null;

  @override
  Future<void> createTeam({
    required String name,
    required String currentUserId,
  }) async {}

  @override
  Future<void> deleteTeam({
    required String teamId,
    required String currentUserId,
  }) async {}

  @override
  Future<void> inviteByEmail({
    required String teamId,
    required String email,
    required String invitationReturnUrl,
  }) async {}

  @override
  Future<void> acceptInvitation({
    required String invitationToken,
  }) async {}

  @override
  Future<void> rejectInvitation({
    required String invitationToken,
  }) async {}

  @override
  Future<void> revokeInvitation({
    required String teamId,
    required String invitationId,
  }) async {}

  @override
  Future<List<Map<String, dynamic>>> loadTeamInvitations(String teamId) async => [];

  @override
  Future<void> updateMemberRole({
    required String teamId,
    required String memberUserId,
    required List<String> roles,
  }) async {}

  @override
  Future<void> removeMember({
    required String teamId,
    required String memberUserId,
    required String currentUserId,
  }) async {}

  @override
  Future<void> leaveTeam({
    required String teamId,
    required String membershipId,
  }) async {}

  @override
  String get teamInvitationReturnUrl => '';
}
