// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана настроек (`settings.*`).
final class SettingsStrings {
  SettingsStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.screenTitle');

  static String toggleThemeTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.toggleThemeTitle');

  static String toggleThemeSubtitle(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.toggleThemeSubtitle');

  static String languageTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.languageTitle');

  static String languageSubtitle(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.languageSubtitle');

  static String languageRu(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.languageRu');

  static String languageEn(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.languageEn');

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'settings.retryBody');
}
