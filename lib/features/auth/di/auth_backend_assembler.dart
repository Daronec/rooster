import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/features/auth/data/sber_id_auth_gateway_impl.dart';
import 'package:rooster/features/auth/domain/gateways/i_auth_gateway.dart';
import 'package:rooster/features/auth/domain/gateways/i_sber_id_gateway.dart';
import 'package:rooster/features/cloud_ru/api/cloud_ru_client.dart';
import 'package:rooster/features/cloud_ru/auth/cloud_ru_auth_service.dart';
import 'package:rooster/features/cloud_ru/sync/cloud_ru_sync_executor.dart';
import 'package:rooster/features/profile/data/teams_gateway_impl.dart';
import 'package:rooster/features/profile/domain/gateways/i_teams_gateway.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Результат сборки auth-бэкенда.
class AuthBackendAssemblyResult {
  /// Создаёт результат.
  AuthBackendAssemblyResult({
    required this.authGateway,
    required this.sberIdGateway,
    required this.cloudRuClient,
    required this.cloudRuSyncExecutor,
    required this.teamsGateway,
  });

  /// Шлюз авторизации.
  final IAuthGateway authGateway;

  /// Шлюз Sber ID.
  final ISberIdGateway sberIdGateway;

  /// Клиент cloud.ru.
  final CloudRuClient cloudRuClient;

  /// Executor синхронизации с cloud.ru.
  final CloudRuSyncExecutor cloudRuSyncExecutor;

  /// Шлюз команд.
  final ITeamsGateway teamsGateway;
}

/// Собирает auth-бэкенд для Sber ID + cloud.ru.
Future<AuthBackendAssemblyResult> assembleAuthBackend({
  required SharedPreferences sharedPreferences,
  required FlutterSecureStorage secureStorage,
  required ILogWriter logger,
  required String serverlessEndpoint,
  required String storageEndpoint,
  required String tokenExchangeEndpoint,
}) async {
  // Создаём cloud.ru сервисы
  final cloudRuAuthService = CloudRuAuthService(
    tokenExchangeEndpoint: tokenExchangeEndpoint,
    logger: logger,
    secureStorage: secureStorage,
  );

  final cloudRuClient = CloudRuClient(
    serverlessEndpoint: serverlessEndpoint,
    storageEndpoint: storageEndpoint,
    iamToken: cloudRuAuthService.iamToken,
    logger: logger,
  );

  // Создаём Sber ID gateway
  final sberIdGateway = SberIdAuthGatewayImpl(
    cloudRuAuthService: cloudRuAuthService,
    cloudRuClient: cloudRuClient,
    logger: logger,
  );

  // Создаём sync executor
  final cloudRuSyncExecutor = CloudRuSyncExecutor(
    cloudRuClient: cloudRuClient,
    logger: logger,
  );

  // Создаём teams gateway
  final teamsGateway = TeamsGatewayImpl(
    cloudRuClient: cloudRuClient,
    logger: logger,
  );

  return AuthBackendAssemblyResult(
    authGateway: sberIdGateway,
    sberIdGateway: sberIdGateway,
    cloudRuClient: cloudRuClient,
    cloudRuSyncExecutor: cloudRuSyncExecutor,
    teamsGateway: teamsGateway,
  );
}
