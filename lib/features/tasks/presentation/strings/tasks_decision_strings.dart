// ignore_for_file: public_member_api_docs

import 'package:flutter/widgets.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_result_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_block_detail_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_missing_material_entity.dart';

/// Строки `tasks.decision.*` (экраны «Решения»).
final class TasksDecisionStrings {
  TasksDecisionStrings._();

  static String mainNavLabel(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.mainNavLabel');

  static String flowTabToday(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.flowTabToday');

  static String flowTabBlocked(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.flowTabBlocked');

  static String flowTabResources(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.flowTabResources');

  static String todayTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.todayTitle');

  static String todaySummary(BuildContext context, {required int count}) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.todaySummary',
      translationParams: <String, String>{'count': '$count'},
    );
  }

  static String todayEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.todayEmpty');

  static String todayLoadError(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.todayLoadError');

  static String todayRetry(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.todayRetry');

  static String todayShowMore(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.todayShowMore');

  static String todayDueNone(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.todayDueNone');

  static String todayCostLabel(BuildContext context, {required double cost}) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.todayCostLabel',
      translationParams: <String, String>{'cost': cost.toString()},
    );
  }

  static String todayScoreLabel(BuildContext context, {required double score}) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.todayScoreLabel',
      translationParams: <String, String>{'score': score.toStringAsFixed(1)},
    );
  }

  static String blockedTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.blockedTitle');

  static String blockedLoadError(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.blockedLoadError');

  static String blockedRetry(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.blockedRetry');

  static String blockedEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.blockedEmpty');

  static String blockedSectionTitle(
    BuildContext context,
    TaskFeasibilityStatusEntity status,
  ) {
    switch (status) {
      case TaskFeasibilityStatusEntity.blockedDependencies:
        return FlutterI18n.translate(
          context,
          'tasks.decision.blockedSectionDependencies',
        );
      case TaskFeasibilityStatusEntity.blockedMoney:
        return FlutterI18n.translate(
          context,
          'tasks.decision.blockedSectionMoney',
        );
      case TaskFeasibilityStatusEntity.blockedMaterials:
        return FlutterI18n.translate(
          context,
          'tasks.decision.blockedSectionMaterials',
        );
      case TaskFeasibilityStatusEntity.ready:
      case TaskFeasibilityStatusEntity.done:
        return status.name;
    }
  }

  /// Краткий текст причины для карточки «Заблокировано».
  static String blockedReasonLine(
    BuildContext context,
    TaskFeasibilityResultEntity result,
  ) {
    final detail = result.detail;
    if (detail == null) {
      return result.status.name;
    }
    switch (result.status) {
      case TaskFeasibilityStatusEntity.blockedMoney:
        final missingText = missingMaterialsText(
          context,
          detail,
          separator: ', ',
        );
        if (missingText.isNotEmpty) {
          return FlutterI18n.translate(
            context,
            'tasks.decision.reasonMoneyMaterials',
            translationParams: <String, String>{
              'deficit': detail.moneyDeficit.toStringAsFixed(0),
              'ids': missingText,
            },
          );
        }
        return FlutterI18n.translate(
          context,
          'tasks.decision.reasonMoney',
          translationParams: <String, String>{
            'deficit': detail.moneyDeficit.toStringAsFixed(0),
          },
        );
      case TaskFeasibilityStatusEntity.blockedMaterials:
        final ids = missingMaterialsText(
          context,
          detail,
          separator: ', ',
        );
        return FlutterI18n.translate(
          context,
          'tasks.decision.reasonMaterials',
          translationParams: <String, String>{'ids': ids},
        );
      case TaskFeasibilityStatusEntity.blockedDependencies:
        final titles = detail.blockingTaskTitles.isNotEmpty
            ? detail.blockingTaskTitles
            : detail.blockingTaskIds;
        return FlutterI18n.translate(
          context,
          'tasks.decision.reasonDependencies',
          translationParams: <String, String>{'ids': titles.join(', ')},
        );
      default:
        return result.status.name;
    }
  }

  static String moneyDeficitLine(
    BuildContext context, {
    required double deficit,
  }) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.reasonMoney',
      translationParams: <String, String>{
        'deficit': deficit.toStringAsFixed(0),
      },
    );
  }

  static String missingMaterialsLine(
    BuildContext context, {
    required String missing,
  }) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.reasonMaterials',
      translationParams: <String, String>{'ids': missing},
    );
  }

  static String purchaseMaterialTaskTitle(
    BuildContext context, {
    required String material,
    required double quantity,
  }) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.purchaseMaterialTaskTitle',
      translationParams: <String, String>{
        'material': material,
        'quantity': _formatQty(quantity),
        'unit': unitPiecesShort(context),
      },
    );
  }

  static String purchaseMaterialTaskDescription(
    BuildContext context, {
    required String material,
    required String tasks,
  }) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.purchaseMaterialTaskDescription',
      translationParams: <String, String>{
        'material': material,
        'tasks': tasks,
      },
    );
  }

  static String purchaseMaterialTooltip(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.purchaseMaterialTooltip');

  static String missingMaterialsText(
    BuildContext context,
    TaskFeasibilityBlockDetailEntity detail, {
    required String separator,
  }) {
    final rich = detail.missingMaterials;
    if (rich.isNotEmpty) {
      final piecesUnitShort = unitPiecesShort(context);
      return rich
          .map(
            (material) =>
                '${material.label} — ${_formatQty(material.missingQuantity)} $piecesUnitShort',
          )
          .join(separator);
    }
    return detail.missingMaterialIds.join(', ');
  }

  static String missingMaterialText(
    BuildContext context,
    TaskMissingMaterialEntity material,
  ) {
    return '${material.label} — ${_formatQty(material.missingQuantity)} ${unitPiecesShort(context)}';
  }

  static String unitPiecesShort(BuildContext context) =>
      FlutterI18n.translate(context, 'common.units.piecesShort');

  static String _formatQty(double value) {
    if (value == value.roundToDouble()) {
      return value.toStringAsFixed(0);
    }
    return value.toStringAsFixed(2).replaceFirst(RegExp(r'\.?0+$'), '');
  }

  static String resourcesTitle(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesTitle');

  static String resourcesBudgetSection(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesBudgetSection');

  static String resourcesYear(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesYear');

  static String resourcesMonth(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesMonth');

  static String resourcesLimit(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesLimit');

  static String resourcesSpent(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesSpent');

  static String resourcesAvailableBudget(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'tasks.decision.resourcesAvailableBudget',
      );

  static String resourcesMaterialsSection(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'tasks.decision.resourcesMaterialsSection',
      );

  static String resourcesShortagesSection(BuildContext context) =>
      FlutterI18n.translate(
        context,
        'tasks.decision.resourcesShortagesSection',
      );

  static String resourcesShortagesEmpty(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesShortagesEmpty');

  static String resourcesShortageLine(
    BuildContext context, {
    required String label,
    required double missing,
    required double required,
    required double available,
    required int taskCount,
  }) {
    return FlutterI18n.translate(
      context,
      'tasks.decision.resourcesShortageLine',
      translationParams: <String, String>{
        'label': label,
        'missing': _formatQty(missing),
        'required': _formatQty(required),
        'available': _formatQty(available),
        'taskCount': '$taskCount',
        'unit': unitPiecesShort(context),
      },
    );
  }

  static String resourcesMaterialId(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesMaterialId');

  static String resourcesMaterialName(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesMaterialName');

  static String resourcesMaterialQty(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesMaterialQty');

  static String resourcesAddMaterial(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesAddMaterial');

  static String resourcesRemoveMaterial(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesRemoveMaterial');

  static String resourcesSaved(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesSaved');

  static String resourcesLoadError(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.resourcesLoadError');

  static String resourcesRetry(BuildContext context) =>
      FlutterI18n.translate(context, 'tasks.decision.retry');
}
