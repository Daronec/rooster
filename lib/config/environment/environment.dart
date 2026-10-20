import 'package:rooster/config/environment/build_type.dart';

/// {@template environment.class}
/// Environment configuration.
/// Only static configurations that are known at compile time are allowed here.
/// {@endtemplate}
class Environment {
  /// {@macro environment.class}
  const Environment({
    required this.buildType,
    this.serverlessEndpoint = '',
    this.storageEndpoint = '',
    this.tokenExchangeEndpoint = '',
    this.bucketName = 'rooster-media',
    this.avatarsBucketName = 'rooster-avatars',
  });

  /// Build type.
  final BuildType buildType;

  /// Endpoint для Cloud.ru Serverless Functions.
  final String serverlessEndpoint;

  /// Endpoint для Cloud.ru Object Storage.
  final String storageEndpoint;

  /// Endpoint для обмена токенов (IAM).
  final String tokenExchangeEndpoint;

  /// Имя бакета для файлов (задачи, аватары и т.д.).
  final String bucketName;

  /// Имя бакета для аватаров пользователей.
  final String avatarsBucketName;

  /// Is this application running in dev mode.
  bool get isDev => buildType == BuildType.dev;

  /// Is this application running in prod mode.
  bool get isProd => buildType == BuildType.prod;
}
