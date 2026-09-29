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
  });

  /// Build type.
  final BuildType buildType;

  /// Endpoint для Yandex Serverless Functions.
  final String serverlessEndpoint;

  /// Endpoint для Yandex Object Storage.
  final String storageEndpoint;

  /// Endpoint для обмена токенов (Yandex IAM).
  final String tokenExchangeEndpoint;

  /// Is this application running in dev mode.
  bool get isDev => buildType == BuildType.dev;

  /// Is this application running in prod mode.
  bool get isProd => buildType == BuildType.prod;
}
