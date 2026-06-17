// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'error_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ErrorDto _$ErrorDtoFromJson(Map<String, dynamic> json) => ErrorDto(
  code: (json['code'] as num).toInt(),
  description: json['description'] as String,
);

Map<String, dynamic> _$ErrorDtoToJson(ErrorDto instance) => <String, dynamic>{
  'code': instance.code,
  'description': instance.description,
};
