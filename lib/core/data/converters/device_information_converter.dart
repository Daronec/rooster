import 'dart:convert';

import 'package:rooster/api/data/device_information_dto.dart';
import 'package:rooster/core/domain/entities/device_information/device_information_entity.dart';
import 'package:rooster/core/domain/entities/device_information/device_type.dart';

/// {@template device_information_converter}
/// Converts [DeviceInformationDto] to [DeviceInformationEntity].
/// {@endtemplate}
class DeviceInformationConverter
    extends Converter<DeviceInformationDto, DeviceInformationEntity> {

  /// {@macro device_information_converter}
  const DeviceInformationConverter({
    required DeviceTypeConverter deviceTypeConverter,
  }) : _deviceTypeConverter = deviceTypeConverter;
  final DeviceTypeConverter _deviceTypeConverter;

  @override
  DeviceInformationEntity convert(DeviceInformationDto input) {
    final os = input.os;

    return DeviceInformationEntity(
      os: os == null ? null : _deviceTypeConverter.convert(os),
      device: input.device,
      osVersion: input.osVersion,
    );
  }
}

/// {@template device_type_converter}
/// Converts [String] to [DeviceType].
/// {@endtemplate}
class DeviceTypeConverter extends Converter<String, DeviceType> {
  /// {@macro device_type_converter}
  const DeviceTypeConverter();

  @override
  DeviceType convert(String input) {
    return DeviceType.values.firstWhere((element) => element.key == input);
  }
}
