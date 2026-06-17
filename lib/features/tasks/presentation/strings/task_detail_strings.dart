// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана деталей задачи (`taskDetail.*`).
final class TaskDetailStrings {
  TaskDetailStrings._();

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.screenTitle');

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.loadingBody');

  static String notFound(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.notFound');

  static String deleted(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.deleted');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.retryBody');

  static String statusCompleted(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.statusCompleted');

  static String statusPending(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.statusPending');

  static String sectionDescription(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionDescription');

  static String noDescription(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.noDescription');

  static String sectionList(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionList');

  static String unknownList(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.unknownList');

  static String sectionDue(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionDue');

  static String noDueDate(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.noDueDate');

  static String sectionTime(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionTime');

  static String sectionTags(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionTags');

  static String sectionSubtasks(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionSubtasks');

  static String addSubtask(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.addSubtask');

  static String noSubtasks(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.noSubtasks');

  static String sectionDependencies(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionDependencies');

  static String noDependencies(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.noDependencies');

  static String dependencyCompleted(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.dependencyCompleted');

  static String dependencyPending(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.dependencyPending');

  static String sectionFinancesAndMaterials(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.sectionFinancesAndMaterials');

  static String budgetTotal(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.budgetTotal');

  static String budgetTotalHint(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.budgetTotalHint');

  static String noMaterials(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.noMaterials');

  static String noTags(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.noTags');

  static String editAction(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.editAction');

  static String shareAction(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.shareAction');

  static String shareSubject(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.shareSubject');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.loadError');

  /// Подсказка доступности: открыть вложение крупно.
  static String openFullscreenSemantics(BuildContext context) =>
      FlutterI18n.translate(context, 'taskDetail.openFullscreenSemantics');

  /// Сообщение для экрана ошибки по исключению модели (`task_not_found` / `task_deleted`).
  static String messageForDetailFailure(
    BuildContext context,
    Exception? exception,
  ) {
    final raw = exception?.toString() ?? '';
    if (raw.contains('task_deleted')) {
      return deleted(context);
    }
    if (raw.contains('task_not_found')) {
      return notFound(context);
    }
    return loadError(context);
  }
}
