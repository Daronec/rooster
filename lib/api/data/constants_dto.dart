import 'package:json_annotation/json_annotation.dart';
import 'package:rooster/api/utils/dto_utils.dart';

part 'constants_dto.g.dart';

/// {@template ConstantsDto}
/// Data transfer object for application constants configuration.
/// {@endtemplate}
@JsonSerializable(includeIfNull: false)
class ConstantsDto {

  /// {@macro ConstantsDto}
  const ConstantsDto({this.supportLink});

  /// Factory from JSON.
  factory ConstantsDto.fromJson(Map<String, dynamic> json) =>
      _$ConstantsDtoFromJson(json);
  /// URL for support page or contact information.
  @JsonKey(name: 'support_link', readValue: DtoUtils.readString)
  final String? supportLink;

  /// To JSON method.
  Map<String, dynamic> toJson() => _$ConstantsDtoToJson(this);
}
