import 'dart:async';
import 'dart:developer' as developer;

/// Запускает [future] без `await`; ошибка перехватывается и не становится
/// «необработанным Future».
///
/// Если задан [onError], он отвечает за логирование и побочные эффекты;
/// иначе пишется запись через [developer.log].
void safeUnawaited(
  Future<void> future, {
  void Function(Object error, StackTrace stackTrace)? onError,
}) {
  unawaited(
    future.catchError((Object error, StackTrace stackTrace) {
      final handler = onError;
      if (handler != null) {
        handler(error, stackTrace);
      } else {
        developer.log(
          'safeUnawaited: async error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }),
  );
}
