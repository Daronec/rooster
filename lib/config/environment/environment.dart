import 'package:rooster/config/environment/build_type.dart';

/// {@template environment.class}
/// Environment configuration.
/// Only static configurations that are known at compile time are allowed here.
/// {@endtemplate}
class Environment {

  /// {@macro environment.class}
  const Environment({required this.buildType});
  /// Build type.
  final BuildType buildType;

  /// Is this application running in dev mode.
  bool get isDev => buildType == BuildType.dev;

  /// Is this application running in prod mode.
  bool get isProd => buildType == BuildType.prod;
}
