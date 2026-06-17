// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана списков задач (`taskLists.*`).
final class TaskListsStrings {
  TaskListsStrings._();

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.retryBody');

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.screenTitle');

  static String deleteConfirmTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.deleteConfirmTitle');

  static String deleteConfirmMessage(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.deleteConfirmMessage');

  static String deleteCancel(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.deleteCancel');

  static String deleteConfirmAction(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.deleteConfirmAction');

  static String deleteSuccess(BuildContext context) =>
      FlutterI18n.translate(context, 'taskLists.deleteSuccess');
}
