import 'package:freezed_annotation/freezed_annotation.dart';

part 'device_check_result.freezed.dart';

/// {@template device_check_result.class}
/// Проверка статуса устройства.
/// {@endtemplate}
@freezed
@immutable
class DeviceCheckResult with _$DeviceCheckResult {
  /// {@macro device_check_result.class}
  const factory DeviceCheckResult.success({
    /// Идентификатор устройства, который присваивает back-end.
    required String deviceId,

    /// Является ли пользователь новым.
    required bool inNewUser,
  }) = DeviceCheckSuccessResult;

  /// {@macro device_check_result.class}
  const factory DeviceCheckResult.deviceBlocked({
    /// Длительность блокировки в минутах.
    required int blockDurationInMinutes,
  }) = DeviceBlockedResult;
}
