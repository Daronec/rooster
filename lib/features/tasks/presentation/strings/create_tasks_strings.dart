// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Строки экрана создания/редактирования задачи (`createTask.*` в JSON).
final class CreateTasksStrings {
  CreateTasksStrings._();

  static String bootstrapLoading(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.bootstrapLoading');

  static String screenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.screenTitle');

  static String editScreenTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.editScreenTitle');

  static String editTaskNotFound(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.editTaskNotFound');

  static String fieldTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldTitle');

  static String fieldTitleHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldTitleHint');

  static String fieldDescription(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldDescription');

  static String fieldDescriptionHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldDescriptionHint');

  static String fieldList(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldList');

  static String fieldExecutor(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldExecutor');

  static String executorPlaceholder(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.executorPlaceholder');

  static String fieldObserver(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldObserver');

  static String observerPlaceholder(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.observerPlaceholder');

  static String participantsEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.participantsEmpty');

  static String ownerLine(BuildContext context, {required String owner}) {
    return FlutterI18n.translate(
      context,
      'createTask.ownerLine',
      translationParams: <String, String>{'owner': owner},
    );
  }

  static String fieldDueDate(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldDueDate');

  static String allDay(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.allDay');

  static String fieldStartTime(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldStartTime');

  static String fieldEndTime(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldEndTime');

  static String sectionReminder(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionReminder');

  static String actionPanelNotifications(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.actionPanelNotifications');

  static String pickCustomReminder(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickCustomReminder');

  static String customReminderValue(
    BuildContext context, {
    required String date,
  }) {
    return FlutterI18n.translate(
      context,
      'createTask.customReminderValue',
      translationParams: <String, String>{'date': date},
    );
  }

  static String reminderPreset(BuildContext context, String presetName) =>
      FlutterI18n.translate(
        context,
        'createTask.reminderPreset_$presetName',
      );

  static String sectionRecurring(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionRecurring');

  static String recurringHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.recurringHint');

  static String pickTime(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickTime');

  static String sectionPriority(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionPriority');

  static String fieldImportance(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldImportance');

  static String fieldComplexity(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldComplexity');

  static String priority(BuildContext context, String priorityName) =>
      FlutterI18n.translate(context, 'createTask.priority_$priorityName');

  static String sectionTag(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionTag');

  static String sectionSubtasks(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionSubtasks');

  static String addSubtask(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.addSubtask');

  static String noSubtasks(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.noSubtasks');

  static String sectionParentTask(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionParentTask');

  static String addParentTask(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.addParentTask');

  static String parentTaskNotSet(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.parentTaskNotSet');

  static String pickParentTaskTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickParentTaskTitle');

  static String pickParentTaskEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickParentTaskEmpty');

  static String pickParentTaskCancel(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickParentTaskCancel');

  static String pickParentTaskClear(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickParentTaskClear');

  static String sectionRequirements(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionRequirements');

  static String fieldEstimatedCost(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldEstimatedCost');

  static String fieldEstimatedCostHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldEstimatedCostHint');

  static String sectionMaterials(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionMaterials');

  static String addMaterialRow(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.addMaterialRow');

  static String removeMaterialRow(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.removeMaterialRow');

  static String materialsAddRowHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.materialsAddRowHint');

  static String fieldMaterialName(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialName');

  static String fieldMaterialNameHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialNameHint');

  static String fieldMaterialQuantity(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialQuantity');

  static String fieldMaterialQuantityHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialQuantityHint');

  static String fieldMaterialCost(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialCost');

  static String fieldMaterialCostHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialCostHint');

  static String fieldMaterialFromStockLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialFromStockLabel');

  static String fieldMaterialFromStockPlaceholder(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'createTask.fieldMaterialFromStockPlaceholder',
      );

  static String fieldMaterialFromStockEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldMaterialFromStockEmpty');

  static String validationMaterialName(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationMaterialName');

  static String validationMaterialQuantity(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationMaterialQuantity');

  static String validationMaterialQuantityFormat(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'createTask.validationMaterialQuantityFormat',
      );

  static String validationMaterialQuantityNegative(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'createTask.validationMaterialQuantityNegative',
      );

  static String validationMaterialCostFormat(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationMaterialCostFormat');

  static String validationMaterialCostNegative(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'createTask.validationMaterialCostNegative',
      );

  static String fieldTagsHint(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.fieldTagsHint');

  static String sectionAttachment(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.sectionAttachment');

  static String pickImage(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickImage');

  static String pickImageFailed(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.pickImageFailed');

  static String removeImage(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.removeImage');

  static String save(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.save');

  static String saving(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.saving');

  static String listsLoading(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.listsLoading');

  static String listsError(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.listsError');

  static String retry(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.retry');

  static String listsEmptyTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.listsEmptyTitle');

  static String listsEmptySubtitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.listsEmptySubtitle');

  static String openListsTab(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.openListsTab');

  static String validationTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationTitle');

  static String validationList(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationList');

  static String validationCustomReminder(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationCustomReminder');

  static String validationEstimatedCost(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.validationEstimatedCost');

  static String validationEstimatedCostNegative(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'createTask.validationEstimatedCostNegative',
      );

  static String saveSuccess(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.saveSuccess');

  static String weekdayMon(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdayMon');

  static String weekdayTue(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdayTue');

  static String weekdayWed(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdayWed');

  static String weekdayThu(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdayThu');

  static String weekdayFri(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdayFri');

  static String weekdaySat(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdaySat');

  static String weekdaySun(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.weekdaySun');

  static String viewChangeHistory(BuildContext context) =>
      FlutterI18n.translate(context, 'createTask.viewChangeHistory');
}
