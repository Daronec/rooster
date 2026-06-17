import 'package:package_info_plus/package_info_plus.dart';
import 'package:rooster/core/domain/entities/app_information/version_and_build_number_couple.dart';

/// {@template app_information_service.dart}
/// Service to handle app specific information.
/// {@endtemplate}
class AppInformationService implements IAppInformationService {
  /// {@macro app_information_service.dart}
  const AppInformationService();

  @override
  Future<VersionAndBuildNumberCouple> getVersionAndBuildNumber() async {
    final packageInfo = await PackageInfo.fromPlatform();

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;

    return VersionAndBuildNumberCouple(
      version: version,
      buildNumber: buildNumber,
    );
  }

  @override
  Future<String> getPackageName() async {
    final packageInfo = await PackageInfo.fromPlatform();

    return packageInfo.packageName;
  }
}

/// {@macro app_information_service.dart}
abstract interface class IAppInformationService {
  /// Get version and build number.
  Future<VersionAndBuildNumberCouple> getVersionAndBuildNumber();

  /// Returns app package name.
  Future<String> getPackageName();
}
