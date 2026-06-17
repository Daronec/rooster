import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/request_operation.dart';
import 'package:rooster/core/domain/entities/app_information/version_and_build_number_couple.dart';

/// {@macro app_information_repository.dart}
abstract interface class IAppInformationRepository {
  /// Get version and build number.
  RequestOperation<VersionAndBuildNumberCouple, Failure>
  getVersionAndBuildNumber();
}
