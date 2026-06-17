import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:rooster/core/domain/entities/device_information/device_type.dart';

part 'device_information_entity.freezed.dart';

/// {@template device_information_entity}
/// Device information entity.
/// Contains information about the device.
/// [os] - Device type.
/// [device] - Device name.
/// [osVersion] - Device OS version.
/// {@endtemplate}
@freezed
abstract class DeviceInformationEntity with _$DeviceInformationEntity {
  /// {@macro device_information_entity}
  const factory DeviceInformationEntity({
    required DeviceType? os,
    required String device,
    required String? osVersion,
  }) = _DeviceInformationEntity;
}
