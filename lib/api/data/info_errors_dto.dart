// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: unused_import, public_member_api_docs, avoid-referencing-discarded-variables, flutter_style_todos, format-comment

import 'package:json_annotation/json_annotation.dart';
import 'package:rooster/api/data/umbrella.dart';
import 'package:rooster/api/utils/dto_utils.dart';

part 'info_errors_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class InfoErrorsDto {

  const InfoErrorsDto({this.field, this.message});

  factory InfoErrorsDto.fromJson(Map<String, dynamic> json) =>
      _$InfoErrorsDtoFromJson(json);
  @JsonKey(name: 'field', readValue: DtoUtils.readString)
  final String? field;

  @JsonKey(name: 'message', readValue: DtoUtils.readString)
  final String? message;

  /// To Json
  Map<String, dynamic> toJson() => _$InfoErrorsDtoToJson(this);
}
