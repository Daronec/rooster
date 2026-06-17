// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'device_information_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DeviceInformationDto _$DeviceInformationDtoFromJson(
  Map<String, dynamic> json,
) => DeviceInformationDto(
  device: json['device'] as String,
  os: json['os'] as String?,
  osVersion: json['osVersion'] as String?,
);

Map<String, dynamic> _$DeviceInformationDtoToJson(
  DeviceInformationDto instance,
) => <String, dynamic>{
  'device': instance.device,
  'os': instance.os,
  'osVersion': instance.osVersion,
};
