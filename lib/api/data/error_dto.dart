// GENERATED CODE - DO NOT MODIFY BY HAND

// ignore_for_file: public_member_api_docs, avoid-referencing-discarded-variables, flutter_style_todos, format-comment

import 'package:json_annotation/json_annotation.dart';

part 'error_dto.g.dart';

@JsonSerializable(includeIfNull: false)
class ErrorDto {

  const ErrorDto({required this.code, required this.description});

  factory ErrorDto.fromJson(Map<String, dynamic> json) =>
      _$ErrorDtoFromJson(json);
  @JsonKey(name: 'code')
  final int code;

  @JsonKey(name: 'description')
  final String description;

  /// To Json
  Map<String, dynamic> toJson() => _$ErrorDtoToJson(this);
}
