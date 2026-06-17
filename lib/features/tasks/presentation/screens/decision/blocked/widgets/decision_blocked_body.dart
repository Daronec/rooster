import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/domain/decision/decision_blocked_section_entity.dart';
import 'package:rooster/features/tasks/domain/decision/task_feasibility_list_entry_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_feasibility_status_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_entity.dart';
import 'package:rooster/features/tasks/domain/entities/task_missing_material_entity.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/util/app_typedefs.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';
import 'package:union_state/union_state.dart';

/// Тело экрана «Заблокировано».
class DecisionBlockedBody extends StatelessWidget {
  /// Создаёт виджет.
  const DecisionBlockedBody({
    required this.bodyState,
    required this.openTask,
    required this.createMaterialPurchaseTask,
    required this.retry,
    super.key,
  });

  /// Состояние секций с заблокированными задачами.
  final UnionStateListenable<List<DecisionBlockedSectionEntity>> bodyState;

  /// Открыть задачу по нажатию на карточку.
  final void Function(TaskEntity task) openTask;

  /// Создать задачу на покупку материала.
  final Future<void> Function({
    required TaskEntity sourceTask,
    required TaskMissingMaterialEntity material,
  })
  createMaterialPurchaseTask;

  /// Повторить загрузку после ошибки.
  final VoidCallback retry;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return UnionStateListenableBuilder<List<DecisionBlockedSectionEntity>>(
      unionStateListenable: bodyState,
      loadingBuilder: (context, last) => const Center(
        child: Padding(
          padding: EdgeInsets.all(AppSizes.double24),
          child: CircularProgressIndicator(),
        ),
      ),
      failureBuilder: (context, exception, last) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                exception?.toString() ??
                    TasksDecisionStrings.blockedLoadError(context),
                style: AppTextStyle.t14.value.copyWith(color: colorScheme.red),
                textAlign: TextAlign.center,
              ),
              const Height(AppSizes.double16),
              FilledButton(
                onPressed: retry,
                child: Text(TasksDecisionStrings.blockedRetry(context)),
              ),
            ],
          ),
        );
      },
      builder: (context, sections) {
        if (sections.isEmpty) {
          return Center(
            child: Text(
              TasksDecisionStrings.blockedEmpty(context),
              style: AppTextStyle.t16.value.copyWith(
                color: colorScheme.gray700,
              ),
              textAlign: TextAlign.center,
            ),
          );
        }
        return ListView.builder(
          itemCount: sections.length,
          itemBuilder: (context, sectionIndex) {
            final section = sections[sectionIndex];
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSizes.double16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    TasksDecisionStrings.blockedSectionTitle(
                      context,
                      section.status,
                    ),
                    style: AppTextStyle.t14Medium.value.copyWith(
                      color: colorScheme.gray900,
                    ),
                  ),
                  const Height(AppSizes.double8),
                  ...section.entries.map(
                    (entry) => _BlockedTaskTile(
                      entry: entry,
                      onOpen: () => openTask(entry.task),
                      onCreateMaterialPurchaseTask: (material) =>
                          createMaterialPurchaseTask(
                            sourceTask: entry.task,
                            material: material,
                          ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

class _BlockedTaskTile extends StatelessWidget {
  const _BlockedTaskTile({
    required this.entry,
    required this.onOpen,
    required this.onCreateMaterialPurchaseTask,
  });

  final TaskFeasibilityListEntryEntity entry;
  final VoidCallback onOpen;
  final Future<void> Function(TaskMissingMaterialEntity material)
  onCreateMaterialPurchaseTask;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final reasonParts = _buildReasonParts(context);
    final semanticsLabel = reasonParts
        .map((reasonPart) => reasonPart.text)
        .whereType<String>()
        .join('. ');
    return Semantics(
      button: true,
      label: semanticsLabel.isEmpty
          ? entry.task.title
          : '${entry.task.title}. $semanticsLabel',
      child: Card(
        margin: const EdgeInsets.only(bottom: AppSizes.double8),
        color: colorScheme.white,
        child: InkWell(
          onTap: onOpen,
          borderRadius: AppSizes.borderRadius8,
          child: Padding(
            padding: AppSizes.edgeInsetsAll16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.task.title,
                  style: AppTextStyle.t16Medium.value.copyWith(
                    color: colorScheme.gray900,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.visible,
                ),
                const Height(AppSizes.double8),
                ...reasonParts.map((part) => _ReasonPartView(part: part)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<_ReasonPart> _buildReasonParts(BuildContext context) {
    final result = entry.feasibility;
    final detail = result.detail;
    if (detail == null) {
      return [
        _ReasonTextPart(
          text: result.status.name,
          bottomPadding: 0,
        ),
      ];
    }

    switch (result.status) {
      case TaskFeasibilityStatusEntity.blockedMoney:
        final parts = <_ReasonPart>[
          _ReasonTextPart(
            text: TasksDecisionStrings.moneyDeficitLine(
              context,
              deficit: detail.moneyDeficit,
            ),
            bottomPadding: AppSizes.double4,
          ),
        ];
        if (detail.missingMaterials.isNotEmpty) {
          parts.addAll(_materialReasonParts(detail.missingMaterials));
        } else {
          parts[0] = _ReasonTextPart(
            text: TasksDecisionStrings.moneyDeficitLine(
              context,
              deficit: detail.moneyDeficit,
            ),
            bottomPadding: 0,
          );
        }
        return parts;
      case TaskFeasibilityStatusEntity.blockedMaterials:
        return _materialReasonParts(detail.missingMaterials);
      case TaskFeasibilityStatusEntity.blockedDependencies:
        return [
          _ReasonTextPart(
            text: TasksDecisionStrings.blockedReasonLine(context, result),
            bottomPadding: 0,
          ),
        ];
      default:
        return [
          _ReasonTextPart(
            text: result.status.name,
            bottomPadding: 0,
          ),
        ];
    }
  }

  List<_ReasonPart> _materialReasonParts(
    List<TaskMissingMaterialEntity> materials,
  ) {
    if (materials.isEmpty) {
      return <_ReasonPart>[
        _ReasonTextPart(
          text: entry.feasibility.status.name,
          bottomPadding: 0,
        ),
      ];
    }

    return materials
        .map(
          (material) => _ReasonMaterialPart(
            material: material,
            onCreate: () => onCreateMaterialPurchaseTask(material),
            bottomPadding: AppSizes.double4,
          ),
        )
        .toList(growable: false);
  }
}

sealed class _ReasonPart {
  const _ReasonPart({required this.bottomPadding});

  final double bottomPadding;

  String? get text;
}

final class _ReasonTextPart extends _ReasonPart {
  const _ReasonTextPart({required this.text, required super.bottomPadding});

  @override
  final String text;
}

final class _ReasonMaterialPart extends _ReasonPart {
  const _ReasonMaterialPart({
    required this.material,
    required this.onCreate,
    required super.bottomPadding,
  });

  final TaskMissingMaterialEntity material;

  final Future<void> Function() onCreate;

  @override
  String get text => material.label;
}

class _ReasonPartView extends StatelessWidget {
  const _ReasonPartView({required this.part});

  final _ReasonPart part;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final reasonPart = part;
    return Padding(
      padding: EdgeInsets.only(bottom: reasonPart.bottomPadding),
      child: switch (reasonPart) {
        _ReasonTextPart() => Text(
          reasonPart.text,
          style: AppTextStyle.t14.value.copyWith(color: colorScheme.gray700),
          softWrap: true,
        ),
        _ReasonMaterialPart() => Row(
          children: <Widget>[
            Expanded(
              child: Text(
                TasksDecisionStrings.missingMaterialsLine(
                  context,
                  missing: TasksDecisionStrings.missingMaterialText(
                    context,
                    reasonPart.material,
                  ),
                ),
                style: AppTextStyle.t14.value.copyWith(
                  color: colorScheme.gray700,
                ),
                softWrap: true,
              ),
            ),
            IconButton(
              tooltip: TasksDecisionStrings.purchaseMaterialTooltip(context),
              onPressed: () => unawaited(reasonPart.onCreate()),
              icon: const Icon(Icons.add),
            ),
          ],
        ),
      },
    );
  }
}
