
import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Общие подписи вкл/выкл и доступности; ключи в [assets/flutter_i18n/ru.json], узел [common].
abstract final class AppStrings {
  /// Включено.
  static String onLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'common.onLabel');

  /// Выключено.
  static String offLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'common.offLabel');

  /// Доступно.
  static String available(BuildContext context) =>
      FlutterI18n.translate(context, 'common.available');

  /// Не доступно.
  static String notAvailable(BuildContext context) =>
      FlutterI18n.translate(context, 'common.notAvailable');
}
