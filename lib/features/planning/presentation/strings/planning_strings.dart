// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки фичи планирования.
abstract final class PlanningStrings {
  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.screenTitle');

  static String mainNavPlan(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.mainNavPlan');

  static String createPlan(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.createPlan');

  static String createTask(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.createTask');

  static String emptyPlans(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.emptyPlans');

  static String planTitleLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.planTitleLabel');

  static String goalLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.goalLabel');

  static String periodLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.periodLabel');

  static String startDateLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.startDateLabel');

  static String endDateLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.endDateLabel');

  static String cancel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.cancel');

  static String save(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.save');

  static String delete(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.delete');

  static String retry(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.retry');

  static String taskTitleLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.taskTitleLabel');

  static String importanceLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.importanceLabel');

  static String noTasks(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.noTasks');

  static String remainingTasks(BuildContext context, int count) =>
      FlutterI18n.translate(
        context,
        'planning.remainingTasks',
        translationParams: <String, String>{'count': '$count'},
      );

  static String completedOf(BuildContext context, int completed, int total) =>
      FlutterI18n.translate(
        context,
        'planning.completedOf',
        translationParams: <String, String>{
          'completed': '$completed',
          'total': '$total',
        },
      );

  static String validationPlanTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.validationPlanTitle');

  static String validationGoal(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.validationGoal');

  static String validationTaskTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.validationTaskTitle');

  /// Строка подтверждения удаления плана.
  static String deleteConfirmTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.deleteConfirmTitle');

  /// Сообщение подтверждения удаления плана.
  static String deleteConfirmMessage(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.deleteConfirmMessage');

  /// Кнопка подтверждения удаления.
  static String deleteConfirmAction(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.deleteConfirmAction');

  /// Заголовок диалога «Выйти без сохранения?».
  static String discardChangesTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.discardChangesTitle');

  /// Сообщение диалога «Выйти без сохранения?».
  static String discardChangesMessage(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.discardChangesMessage');

  /// Кнопка «Выйти» в диалоге отмены.
  static String discardChangesAction(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.discardChangesAction');

  /// Строка ошибки: план не найден.
  static String planNotFound(BuildContext context) =>
      FlutterI18n.translate(context, 'planning.planNotFound');
}
