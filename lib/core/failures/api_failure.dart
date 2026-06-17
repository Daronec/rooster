import 'package:rooster/api/data/info_errors_dto.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';

/// {@template api_failure.class}
/// API error.
/// {@endtemplate}
base class ApiFailure extends Failure<Exception> {

  /// {@macro api_failure.class}
  const ApiFailure({
    required super.original,
    required super.trace,
    this.statusCode,
    this.responseBodyCode,
    this.message,
    this.infoErrors = const [],
  });
  /// Special error status code parsed from the response body.
  /// Special status codes are described below and are checked through getters.
  final int? statusCode;

  /// Original error status code from [Exception].
  final int? responseBodyCode;

  /// Message.
  final String? message;

  /// List of errors.
  final List<InfoErrorsDto> infoErrors;

  /// Номер пользователя не найден.
  bool get isPhoneNumberNotFound => statusCode == 4001;

  /// Истек срок действия ОТР кода.
  bool get isOtpExpired => statusCode == 4002;

  /// Указан неверный одноразовый код.
  bool get isOtpIncorrect => statusCode == 4003;

  /// Превышен лимит одновременных сессий.
  bool get isSessionsExceeded => statusCode == 4004;

  /// Пустой поисковый запрос.
  bool get isEmptyRequest => statusCode == 4005;

  /// Создаваемое контактное лицо контрагента уже существует.
  bool get isAgentAlreadyExists => statusCode == 4006;

  /// Невалидное сочетание параметров запроса.
  bool get isParametersInvalid => statusCode == 4007;

  /// Ошибка загрузки файла на сервер.
  bool get isFileUploadFailed => statusCode == 4008;

  /// Ошибка создания встречи.
  bool get isMeetingCreationFailed => statusCode == 4009;

  /// Ошибка удаления.
  bool get isDeletionFailed => statusCode == 4010;

  /// Ошибка просмотра расписания.
  bool get isScheduleViewFailed => statusCode == 4011;

  /// Description of the API failure.
  ///
  /// If [infoErrors] is not empty, the first error message is returned.
  ///
  /// Otherwise, the [message] is returned.
  String? get description => infoErrors.firstOrNull?.message ?? message;
}

/// {@template no_internet_failure.class}
/// NoInternet Exception.
/// {@endtemplate}
final class NoInternetFailure extends ApiFailure {
  /// {@macro no_internet_failure.class}
  const NoInternetFailure({
    required super.original,
    required super.trace,
    super.statusCode,
  });

  @override
  String toString() {
    return 'NoInternetFailure{statusCode: ${statusCode ?? 'null'}, original: $original}';
  }
}

/// {@template timeout_failure.class}
/// Timeout Exception.
/// {@endtemplate}
final class TimeoutFailure extends ApiFailure {
  /// {@macro timeout_failure.class}
  const TimeoutFailure({
    required super.original,
    required super.trace,
    super.statusCode,
  });

  @override
  String toString() {
    return 'TimeoutFailure{statusCode: ${statusCode ?? 'null'}, original: $original}';
  }
}

/// {@template server_internal_failure.class}
/// Server Internal Exception.
/// {@endtemplate}
final class ServerInternalFailure extends ApiFailure {
  /// {@macro server_internal_failure.class}
  const ServerInternalFailure({
    required super.original,
    required super.trace,
    super.statusCode,
  });

  @override
  String toString() {
    return 'ServerInternalFailure{statusCode: ${statusCode ?? 'null'}, original: $original}';
  }
}
