import 'package:rooster/core/sync/i_sync_manager.dart';
import 'package:rooster/core/sync/i_sync_remote_executor.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_avatar_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_profile_personal_data_gateway.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';

import 'package:rooster/integration/network/connectivity_gateway.dart';

/// Результат сборки одной стратегии облачной авторизации.
final class AuthBackendAssemblyResult {
  /// Создаёт результат.
  const AuthBackendAssemblyResult({
    required this.authGateway,
    required this.remoteExecutor,
    required this.profilePersonalDataGateway,
    required this.profileAvatarGateway,
    required this.teamsGateway,
    this.bindInboundCloudSync,
  });

  /// Шлюз входа и сессии.
  final IAuthGateway authGateway;

  /// Исполнитель удалённой синхронизации очереди.
  final ISyncRemoteExecutor remoteExecutor;

  /// Персональные данные профиля в облаке.
  final IProfilePersonalDataGateway profilePersonalDataGateway;

  /// Аватар профиля в облаке.
  final IProfileAvatarGateway profileAvatarGateway;

  /// Команды Appwrite; при офлайне — реализация без сетевых вызовов.
  final ITeamsGateway teamsGateway;

  /// Входящая синхронизация (pull) после привязки [ISyncManager]; только ветка Appwrite с Databases.
  final void Function(ISyncManager syncManager, IConnectivityGateway connectivity)?
      bindInboundCloudSync;
}
