import 'package:rooster/core/architecture/data/repository/base_repository.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/request_operation.dart';
import 'package:rooster/core/data/converters/device_information_converter.dart';
import 'package:rooster/core/domain/entities/device_information/device_information_entity.dart';
import 'package:rooster/core/domain/repository/i_device_information_repository.dart';
import 'package:rooster/core/domain/service/device_information_service.dart';

/// {@macro device_information_repository}
class DeviceInformationRepository extends BaseRepository
    implements IDeviceInformationRepository {

  /// {@macro device_information_repository}
  DeviceInformationRepository({
    required super.logWriter,
    required IDeviceInformationService deviceInformationService,
    required DeviceInformationConverter deviceInformationConverter,
  }) : _deviceInformationService = deviceInformationService,
       _deviceInformationConverter = deviceInformationConverter;
  final IDeviceInformationService _deviceInformationService;

  final DeviceInformationConverter _deviceInformationConverter;

  @override
  RequestOperation<DeviceInformationEntity?, Failure<Exception>>
  getDeviceInformation() => makeCall(() async {
    final deviceInformation = await _deviceInformationService
        .getDeviceInformation();

    if (deviceInformation == null) {
      return null;
    }

    return _deviceInformationConverter.convert(deviceInformation);
  });
}
