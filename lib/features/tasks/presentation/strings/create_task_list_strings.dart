// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана создания списка (`createTaskList.*`).
final class CreateTaskListStrings {
  CreateTaskListStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.screenTitle');

  static String editScreenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.editScreenTitle');

  static String fieldName(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.fieldName');

  static String fieldNameHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.fieldNameHint');

  static String colorLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.colorLabel');

  static String save(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.save');

  static String submitEdit(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.submitEdit');

  static String cancel(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.cancel');

  static String validationNameEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.validationNameEmpty');

  static String successSnack(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.successSnack');

  static String updateSuccessSnack(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.updateSuccessSnack');

  static String editListNotFound(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.editListNotFound');

  static String fabTooltip(BuildContext context) =>
      FlutterI18n.translate(context, 'createTaskList.fabTooltip');
}
