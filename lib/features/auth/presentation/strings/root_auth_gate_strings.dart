// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки корневого шлюза авторизации (`rootAuthGate.*`).
final class RootAuthGateStrings {
  RootAuthGateStrings._();

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'rootAuthGate.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'rootAuthGate.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'rootAuthGate.retryBody');
}
