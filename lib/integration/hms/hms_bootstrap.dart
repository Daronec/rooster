import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:rooster/common/utils/logger/i_log_writer.dart';
import 'package:rooster/integration/analytics/huawei_app_analytics_gateway_impl.dart'
    show HuaweiAppAnalyticsGatewayImpl;

/// Инициализация HMS/AGConnect без Firebase (стратегия Huawei).
///
/// Analytics поднимается лениво в [HuaweiAppAnalyticsGatewayImpl].
final class HmsBootstrap {
  /// Включает сбор крашей AGC и перехват ошибок Flutter.
  static Future<void> initialize(ILogWriter logger) async {
    if (kIsWeb || !Platform.isAndroid) {
      if (kDebugMode) {
        logger.log('hms_bootstrap_skipped_non_android');
      }
      return;
    }
    try {
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
      };
      PlatformDispatcher.instance.onError = (error, stack) {
        return true;
      };
      if (kDebugMode) {
        logger.log('hms_bootstrap_crash_collection enabled=${!kDebugMode}');
      }
    } on Object catch (e, st) {
      logger.exception(e, st);
    }
  }
}
