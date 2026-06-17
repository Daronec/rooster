import 'package:dio/dio.dart';
import 'package:rooster/api/data/umbrella.dart';
import 'package:rooster/common/utils/disposable_object/disposable_object.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/core/architecture/domain/entity/failure.dart';
import 'package:rooster/core/architecture/domain/entity/request_operation.dart';
import 'package:rooster/core/architecture/domain/entity/result.dart';
import 'package:rooster/core/failures/api_failure.dart';
import 'package:rooster/util/extensions/closures.dart';

/// Request operation wrapper.
typedef OperationWrapper<T, E extends Failure> = Future<T> Function();

/// Базовый класс для всех репозиториев.
abstract class BaseRepository extends DisposableObject {

  /// Base repository constructor.
  BaseRepository({required this.logWriter});
  /// Logger.
  final ILogWriter logWriter;

  /// Обертка для запросов.
  RequestOperation<T, Failure> makeCall<T, E extends ApiFailure>(
    OperationWrapper<T, E> request,
  ) async {
    try {
      return ResultOk(await request());
    } on DioException catch (exception, s) {
      logWriter.exception(exception, s);

      return Result.failed(mapApiError(exception, trace: s));
    } on Exception catch (exception, s) {
      logWriter.exception(exception, s);

      return Result.failed(ApiFailure(original: exception, trace: s));
    } on Object catch (exception, s) {
      logWriter.exception(exception, s);

      return Result.failed(
        ApiFailure(original: Exception('Unknown error: $exception'), trace: s),
      );
    }
  }

  /// API error mapping.
  ApiFailure mapApiError(DioException error, {required StackTrace trace}) {
    final statusCode = error.response?.statusCode;

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          original: error,
          trace: trace,
          statusCode: statusCode,
        );
      case DioExceptionType.connectionError:
        return NoInternetFailure(
          original: error,
          trace: trace,
          statusCode: statusCode,
        );
      case DioExceptionType.badResponse:
        if (statusCode?.let((it) => it > 500 && it < 600) ?? false) {
          return ServerInternalFailure(
            original: error,
            trace: trace,
            statusCode: statusCode,
          );
        }

        final responseBody = error.response?.data;

        if (responseBody != null) {
          try {
            final errorObject = ErrorDto.fromJson(
              responseBody as Map<String, dynamic>,
            );

            return ApiFailure(
              original: error,
              trace: trace,
              statusCode: errorObject.code,
              responseBodyCode: statusCode,
              message: errorObject.description,
            );
          } on Object {
            // Do nothing.
          }
        }

        return ApiFailure(
          original: error,
          trace: trace,
          responseBodyCode: statusCode,
        );
      default:
        break;
    }

    return ApiFailure(original: error, trace: trace, statusCode: statusCode);
  }
}
