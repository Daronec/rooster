import 'package:rooster/core/architecture/data/repository/base_repository.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/request_operation.dart';
import 'package:rooster/core/domain/entities/app_information/version_and_build_number_couple.dart';
import 'package:rooster/core/domain/repository/i_app_information_repository.dart';
import 'package:rooster/core/domain/service/app_information_service.dart';

/// {@template app_information_repository.dart}
/// Repository to handle app specific information.
/// {@endtemplate}
class AppInformationRepository extends BaseRepository
    implements IAppInformationRepository {

  /// {@macro app_information_repository.dart}
  AppInformationRepository({
    required IAppInformationService appInformationService,
    required super.logWriter,
  }) : _appInformationService = appInformationService;
  final IAppInformationService _appInformationService;

  @override
  RequestOperation<VersionAndBuildNumberCouple, Failure>
  getVersionAndBuildNumber() =>
      makeCall(_appInformationService.getVersionAndBuildNumber);
}
