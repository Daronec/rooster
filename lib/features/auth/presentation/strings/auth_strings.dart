// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана входа (`auth.*`).
final class AuthStrings {
  AuthStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'auth.screenTitle');

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'auth.loadingBody');

  static String loadBodyError(BuildContext context) =>
      FlutterI18n.translate(context, 'auth.loadBodyError');

  static String retryLoadBody(BuildContext context) =>
      FlutterI18n.translate(context, 'auth.retryLoadBody');
}
