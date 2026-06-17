// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'info_errors_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InfoErrorsDto _$InfoErrorsDtoFromJson(Map<String, dynamic> json) =>
    InfoErrorsDto(
      field: DtoUtils.readString(json, 'field') as String?,
      message: DtoUtils.readString(json, 'message') as String?,
    );

Map<String, dynamic> _$InfoErrorsDtoToJson(InfoErrorsDto instance) =>
    <String, dynamic>{'field': ?instance.field, 'message': ?instance.message};
