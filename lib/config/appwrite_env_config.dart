import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Параметры Appwrite из [dotenv] (файл `.env` в assets).
///
/// Ключи: `APPWRITE_PROJECT_ID`, `APPWRITE_PUBLIC_ENDPOINT`,
/// `APPWRITE_OAUTH_SUCCESS_URL`, `APPWRITE_OAUTH_FAILURE_URL`,
/// `APPWRITE_PASSWORD_RECOVERY_REDIRECT_URL`,
/// `APPWRITE_TEAM_INVITE_RETURN_URL`.
///
/// Синхронизация в Databases + Storage (опционально):
/// `APPWRITE_SYNC_DATABASE_ID`, `APPWRITE_SYNC_TASKS_COLLECTION_ID`,
/// `APPWRITE_SYNC_LISTS_COLLECTION_ID`, `APPWRITE_SYNC_PLANS_COLLECTION_ID`,
/// `APPWRITE_SYNC_MATERIALS_COLLECTION_ID`, `APPWRITE_SYNC_TASK_IMAGES_BUCKET_ID`.
///
/// Отключение: `APPWRITE_DISABLED=true` в `.env`.
///
/// Значения по умолчанию (после [loadAppDotEnv]): проект `rooster`, endpoint FRA.
final class AppwriteEnvConfig {
  /// Создаёт конфиг с явными значениями (тесты).
  const AppwriteEnvConfig({
    required this.projectId,
    required this.publicEndpoint,
    required this.oauthSuccessUrl,
    required this.oauthFailureUrl,
    required this.passwordRecoveryRedirectUrl,
    required this.teamInviteReturnUrl,
    this.disabled = false,
    this.syncDatabaseId = '',
    this.syncTasksCollectionId = '',
    this.syncListsCollectionId = '',
    this.syncPlansCollectionId = '',
    this.syncMaterialsCollectionId = '',
    this.syncTaskImagesBucketId = '',
    this.debugTeamsProbeTeamId = '',
  });

  /// Идентификатор проекта по умолчанию.
  static const String defaultProjectId = 'rooster';

  /// Endpoint по умолчанию (FRA).
  static const String defaultPublicEndpoint = 'https://fra.cloud.appwrite.io/v1';

  /// Схема редиректа OAuth (зарегистрируйте платформу в консоли Appwrite).
  static const String defaultOauthSuccessUrl = 'appwrite-callback-rooster://';

  /// Редирект при ошибке OAuth.
  static const String defaultOauthFailureUrl = 'appwrite-callback-rooster://failure';

  /// URL для письма восстановления пароля.
  static const String defaultPasswordRecoveryRedirectUrl =
      'appwrite-callback-rooster://recovery';

  /// Redirect URL для подтверждения приглашения в команду Appwrite.
  static const String defaultTeamInviteReturnUrl =
      'appwrite-callback-rooster://team-invite';

  /// Читает переменные из [dotenv] (нужен предварительный [loadAppDotEnv]).
  factory AppwriteEnvConfig.fromDotenv() {
    if (!dotenv.isInitialized) {
      return const AppwriteEnvConfig(
        projectId: '',
        publicEndpoint: '',
        oauthSuccessUrl: '',
        oauthFailureUrl: '',
        passwordRecoveryRedirectUrl: '',
        teamInviteReturnUrl: '',
        disabled: true,
      );
    }
    final environment = dotenv.env;
    final disabledRaw = environment['APPWRITE_DISABLED']?.trim().toLowerCase();
    final disabled = disabledRaw == '1' ||
        disabledRaw == 'true' ||
        disabledRaw == 'yes';
    return AppwriteEnvConfig(
      projectId:
          environment['APPWRITE_PROJECT_ID']?.trim() ?? defaultProjectId,
      publicEndpoint:
          environment['APPWRITE_PUBLIC_ENDPOINT']?.trim() ??
              defaultPublicEndpoint,
      oauthSuccessUrl:
          environment['APPWRITE_OAUTH_SUCCESS_URL']?.trim() ??
              defaultOauthSuccessUrl,
      oauthFailureUrl:
          environment['APPWRITE_OAUTH_FAILURE_URL']?.trim() ??
              defaultOauthFailureUrl,
      passwordRecoveryRedirectUrl:
          environment['APPWRITE_PASSWORD_RECOVERY_REDIRECT_URL']?.trim() ??
              defaultPasswordRecoveryRedirectUrl,
      teamInviteReturnUrl:
          environment['APPWRITE_TEAM_INVITE_RETURN_URL']?.trim() ??
              defaultTeamInviteReturnUrl,
      disabled: disabled,
      syncDatabaseId: environment['APPWRITE_SYNC_DATABASE_ID']?.trim() ?? '',
      syncTasksCollectionId:
          environment['APPWRITE_SYNC_TASKS_COLLECTION_ID']?.trim() ?? '',
      syncListsCollectionId:
          environment['APPWRITE_SYNC_LISTS_COLLECTION_ID']?.trim() ?? '',
      syncPlansCollectionId:
          environment['APPWRITE_SYNC_PLANS_COLLECTION_ID']?.trim() ?? '',
      syncMaterialsCollectionId:
          environment['APPWRITE_SYNC_MATERIALS_COLLECTION_ID']?.trim() ?? '',
      syncTaskImagesBucketId:
          environment['APPWRITE_SYNC_TASK_IMAGES_BUCKET_ID']?.trim() ?? '',
      debugTeamsProbeTeamId:
          environment['APPWRITE_DEBUG_TEAMS_PROBE_TEAM_ID']?.trim() ?? '',
    );
  }

  /// Идентификатор проекта Appwrite.
  final String projectId;

  /// Публичный HTTP endpoint (`…/v1`).
  final String publicEndpoint;

  /// Success redirect для [Account.createOAuth2Session].
  final String oauthSuccessUrl;

  /// Failure redirect для OAuth.
  final String oauthFailureUrl;

  /// Redirect URL для [Account.createRecovery].
  final String passwordRecoveryRedirectUrl;

  /// Redirect URL для подтверждения приглашения в команду Appwrite.
  final String teamInviteReturnUrl;

  /// Явное отключение через `.env`.
  final bool disabled;

  /// Идентификатор базы данных с коллекциями задач и списков.
  final String syncDatabaseId;

  /// Коллекция документов задач пользователя.
  final String syncTasksCollectionId;

  /// Коллекция документов списков задач.
  final String syncListsCollectionId;

  /// Коллекция планов (включая вложенные задачи плана).
  final String syncPlansCollectionId;

  /// Коллекция снимков склада материалов (один документ на пользователя).
  final String syncMaterialsCollectionId;

  /// Bucket Storage для изображений вложений задач.
  final String syncTaskImagesBucketId;

  /// Debug: teamId для дополнительной диагностики Teams API (только для dev).
  ///
  /// Если задано, в debug-сборке можно логировать результаты `Teams.get(teamId)`
  /// и `Teams.listMemberships(teamId)` при пустом `Teams.list()`.
  final String debugTeamsProbeTeamId;

  /// Достаточно данных для [Client] и ветки авторизации Appwrite.
  bool get isClientConfigured =>
      !disabled &&
      projectId.trim().isNotEmpty &&
      publicEndpoint.trim().isNotEmpty;

  /// Настроены идентификаторы Databases и bucket для исходящей/входящей синхронизации.
  bool get isSyncDatabaseConfigured =>
      syncDatabaseId.trim().isNotEmpty &&
      syncTasksCollectionId.trim().isNotEmpty &&
      syncListsCollectionId.trim().isNotEmpty &&
      syncPlansCollectionId.trim().isNotEmpty &&
      syncMaterialsCollectionId.trim().isNotEmpty &&
      syncTaskImagesBucketId.trim().isNotEmpty;
}
