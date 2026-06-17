// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки dev-панели (`devPanel.*`).
final class DevPanelStrings {
  DevPanelStrings._();

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'devPanel.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'devPanel.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'devPanel.retryBody');
}
