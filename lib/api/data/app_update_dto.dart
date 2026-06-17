import 'package:json_annotation/json_annotation.dart';
import 'package:rooster/api/utils/dto_utils.dart';

part 'app_update_dto.g.dart';

/// {@template UpdateDto}
/// Update data for the app from
/// remote configuration service.
/// {@endtemplate}
@JsonSerializable(includeIfNull: false)
class AppUpdateDto {

  /// {@macro UpdateDto}
  const AppUpdateDto({
    required this.minVersion,
    required this.actualVersion,
    required this.appLink,
  });

  /// Factory from JSON.
  factory AppUpdateDto.fromJson(Map<String, dynamic> json) =>
      _$AppUpdateDtoFromJson(json);
  /// Minimum allowed version.
  ///
  /// If current version of the app is lower,
  /// then force update is conducted.
  @JsonKey(name: 'minVersion', readValue: DtoUtils.readString)
  final String? minVersion;

  /// Actual version.
  ///
  /// Represents last version published in app stores.
  ///
  /// If current version of the app is lower,
  /// then soft update popup is shown.
  @JsonKey(name: 'actualVersion', readValue: DtoUtils.readString)
  final String? actualVersion;

  /// Link leading to stores.
  @JsonKey(name: 'appLink', readValue: DtoUtils.readString)
  final String? appLink;

  /// To JSON method.
  Map<String, dynamic> toJson() => _$AppUpdateDtoToJson(this);
}
