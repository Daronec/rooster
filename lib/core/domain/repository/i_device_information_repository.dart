import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/request_operation.dart';
import 'package:rooster/core/domain/entities/device_information/device_information_entity.dart';

/// {@macro device_information_repository.dart}
abstract interface class IDeviceInformationRepository {
  /// Get Device information.
  RequestOperation<DeviceInformationEntity?, Failure> getDeviceInformation();
}
