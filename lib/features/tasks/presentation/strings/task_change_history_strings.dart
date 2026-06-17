// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана истории изменений (`taskChangeHistory.*`).
final class TaskChangeHistoryStrings {
  TaskChangeHistoryStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.screenTitle');

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.retryBody');

  static String emptyState(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.emptyState');

  static String kindCreated(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.kindCreated');

  static String kindUpdated(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.kindUpdated');

  static String kindDeleted(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.kindDeleted');

  static String authorLine(BuildContext context, {required String author}) {
    return FlutterI18n.translate(
      context,
      'taskChangeHistory.authorLine',
      translationParams: <String, String>{'author': author},
    );
  }

  static String unknownAuthor(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.unknownAuthor');

  static String fieldTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldTitle');

  static String fieldDescription(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldDescription');

  static String fieldList(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldList');

  static String fieldParentTask(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldParentTask');

  static String fieldExecutor(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldExecutor');

  static String fieldObserver(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldObserver');

  static String fieldDueDate(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldDueDate');

  static String fieldTime(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldTime');

  static String fieldPriority(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldPriority');

  static String fieldTags(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldTags');

  static String fieldStatus(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldStatus');

  static String fieldEstimatedCost(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldEstimatedCost');

  static String fieldMaterials(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldMaterials');

  static String fieldAttachment(BuildContext context) =>
      FlutterI18n.translate(context, 'taskChangeHistory.fieldAttachment');

  static String updatedFields(BuildContext context, {required String fields}) {
    return FlutterI18n.translate(
      context,
      'taskChangeHistory.updatedFields',
      translationParams: <String, String>{'fields': fields},
    );
  }
}
