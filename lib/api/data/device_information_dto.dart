// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_import, public_member_api_docs, avoid-referencing-discarded-variables, flutter_style_todos, format-comment

import 'package:json_annotation/json_annotation.dart';
import 'package:rooster/api/data/umbrella.dart';

part 'device_information_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class DeviceInformationDto {

  const DeviceInformationDto({required this.device, this.os, this.osVersion});

  factory DeviceInformationDto.fromJson(Map<String, dynamic> json) =>
      _$DeviceInformationDtoFromJson(json);
  @JsonKey(name: 'device')
  final String device;

  @JsonKey(name: 'os', includeIfNull: true)
  final String? os;

  @JsonKey(name: 'osVersion', includeIfNull: true)
  final String? osVersion;

  /// To Json
  Map<String, dynamic> toJson() => _$DeviceInformationDtoToJson(this);
}
