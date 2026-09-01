import 'package:rooster/features/auth/data/offline_auth_gateway.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_context.dart';
import 'package:rooster/features/auth/di/auth_backend_assembly_result.dart';
import 'package:rooster/features/auth/di/i_auth_backend_assembly_strategy.dart';
import 'package:rooster/features/auth/domain/auth_backend_strategy.dart';
import 'package:rooster/features/auth/domain/cloud_auth_unavailable_reason.dart';
import 'package:rooster/features/profile/data/noop_profile_avatar_gateway_impl.dart';
import 'package:rooster/features/profile/data/noop_profile_personal_data_gateway_impl.dart';
import 'package:rooster/features/profile/data/noop_teams_gateway_impl.dart';
import 'package:rooster/integration/sync/local_only_sync_executor.dart';

/// Нет облачного входа: локальный шлюз и noop-профиль.
final class OfflineAuthBackendAssemblyStrategy
    implements IAuthBackendAssemblyStrategy {
  /// Создаёт стратегию.
  const OfflineAuthBackendAssemblyStrategy();

  @override
  Future<AuthBackendAssemblyResult?> tryAssemble(
    AuthBackendAssemblyContext context,
  ) async {
    if (context.authBackendStrategy == AuthBackendStrategy.appwrite) {
      return null;
    }
    final authGateway = OfflineAuthGateway(
      context.logger,
      unavailableReason: CloudAuthUnavailableReason.appwriteNotConfigured,
    );
    return AuthBackendAssemblyResult(
      authGateway: authGateway,
      remoteExecutor: const LocalOnlySyncExecutor(),
      profilePersonalDataGateway: const NoopProfilePersonalDataGatewayImpl(),
      profileAvatarGateway: const NoopProfileAvatarGatewayImpl(),
      teamsGateway: const NoopTeamsGatewayImpl(),
    );
  }
}
