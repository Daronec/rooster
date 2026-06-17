// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки боковой панели десктопа; ключи в [assets/flutter_i18n/ru.json], узел [mainDesktopNav].
abstract final class MainDesktopNavigationStrings {
  static String summary(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.summary');

  static String home(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.home');

  static String rooms(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.rooms');

  static String systems(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.systems');

  static String scenes(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.scenes');

  static String allSystemsOk(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.allSystemsOk');

  static String extraMenu(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.extraMenu');

  static String settings(BuildContext context) =>
      FlutterI18n.translate(context, 'mainDesktopNav.settings');
}
