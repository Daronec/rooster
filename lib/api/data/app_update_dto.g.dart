// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_update_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AppUpdateDto _$AppUpdateDtoFromJson(Map<String, dynamic> json) => AppUpdateDto(
  minVersion: DtoUtils.readString(json, 'minVersion') as String?,
  actualVersion: DtoUtils.readString(json, 'actualVersion') as String?,
  appLink: DtoUtils.readString(json, 'appLink') as String?,
);

Map<String, dynamic> _$AppUpdateDtoToJson(AppUpdateDto instance) =>
    <String, dynamic>{
      'minVersion': ?instance.minVersion,
      'actualVersion': ?instance.actualVersion,
      'appLink': ?instance.appLink,
    };
