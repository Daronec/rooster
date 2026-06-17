/// {@template version_and_build_number_couple.dart}
/// Record for version and build number couple.
/// {@endtemplate}
final class VersionAndBuildNumberCouple {

  /// {@macro version_and_build_number_couple.dart}
  const VersionAndBuildNumberCouple({
    required this.version,
    required this.buildNumber,
  });
  /// Version of app.
  final String version;

  /// Build number of app.
  final String buildNumber;
}
