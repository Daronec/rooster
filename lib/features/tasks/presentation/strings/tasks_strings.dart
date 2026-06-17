// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки фичи списка задач (`tasks.*` в JSON локализации).
final class TasksStrings {
  TasksStrings._();

  static String menuMore(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.menuMore');

  static String menuEdit(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.menuEdit');

  static String menuDelete(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.menuDelete');

  static String menuPin(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.menuPin');

  static String menuUnpin(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.menuUnpin');

  static String menuCancel(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.menuCancel');

  static String pinnedGroupTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.pinnedGroupTitle');

  static String dueToday(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.dueToday');

  static String dueYesterday(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.dueYesterday');

  static String dueTomorrow(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.dueTomorrow');

  static String deleteConfirmTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.deleteConfirmTitle');

  static String deleteConfirmMessage(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.deleteConfirmMessage');

  static String deleteCancel(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.deleteCancel');

  static String deleteConfirmAction(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.deleteConfirmAction');

  static String deleteSuccess(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.deleteSuccess');

  static String checkboxMarkCompleted(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.checkboxMarkCompleted');

  static String checkboxMarkPending(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.checkboxMarkPending');

  static String loadingBody(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.loadingBody');

  static String loadError(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.loadError');

  static String retryBody(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.retryBody');

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.screenTitle');

  static String emptyState(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.emptyState');

  static String unknownList(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.unknownList');

  static String groupTaskCount(BuildContext context, {required int count}) {
    return FlutterI18n.translate(
      context,
      'tasks.groupTaskCount',
      translationParams: <String, String>{'count': '$count'},
    );
  }

  static String sectionNotCompleted(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.sectionNotCompleted');

  static String sectionCompleted(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.sectionCompleted');

  static String mainNavTasks(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.mainNavTasks');

  static String mainNavLists(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.mainNavLists');

  static String mainNavDecisions(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.mainNavDecisions');

  static String mainNavProfile(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.mainNavProfile');

  static String mainNavSettings(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.mainNavSettings');

  static String decisionDebugPanelTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.debugPanelTitle');

  static String decisionDebugTodaySection(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.debugTodaySection');

  static String decisionDebugBlockedSection(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.debugBlockedSection');

  static String decisionDebugEmptyToday(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.debugEmptyToday');

  static String decisionDebugEmptyBlocked(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.debugEmptyBlocked');

  static String decisionDebugScoreLabel(
    BuildContext context, {
    required double score,
  }) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.debugScoreLabel',
      translationParams: <String, String>{'score': score.toStringAsFixed(1)},
    );
  }
}
