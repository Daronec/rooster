import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';

/// Заглушка: стек Firebase отключён (пакеты закомментированы в [pubspec.yaml]).
///
/// Раньше здесь инициализировались Core, Crashlytics, Messaging, Remote Config,
/// Performance и Analytics.
final class FirebaseBootstrap {
  FirebaseBootstrap._();

  /// Всегда возвращает `false`; реальной инициализации нет.
  static Future<bool> initialize(ILogWriter logger) async {
    if (kDebugMode) {
      logger.log('firebase_bootstrap_skipped');
    }
    return false;
  }
}
