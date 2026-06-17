import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_form_state_entity.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/decision_resources_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/widgets/material_item.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Форма редактирования бюджета и склада.
final class DecisionResourcesEditor extends StatelessWidget {
  /// Создаёт редактор.
  const DecisionResourcesEditor({
    required this.wm,
    required this.onRetryLoad,
    super.key,
  });

  /// Widget model.
  final DecisionResourcesScreenWidgetModel wm;

  /// Повторить загрузку (если форма ещё не готова).
  final VoidCallback onRetryLoad;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final state = wm.formState;
    if (state == null) {
      return Center(
        child: FilledButton(
          onPressed: onRetryLoad,
          child: Text(TasksDecisionStrings.resourcesRetry(context)),
        ),
      );
    }
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            TasksDecisionStrings.resourcesBudgetSection(context),
            style: AppTextStyle.t16Medium.value.copyWith(
              color: colorScheme.gray900,
            ),
          ),
          const Height(AppSizes.double12),
          AppTextField(
            controller: state.limitController,
            decoration: InputDecoration(
              labelText: TasksDecisionStrings.resourcesAvailableBudget(context),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          const Height(AppSizes.double24),
          _MaterialShortagesBlock(state: state, wm: wm),
          const Height(AppSizes.double24),
          Text(
            TasksDecisionStrings.resourcesMaterialsSection(context),
            style: AppTextStyle.t16Medium.value.copyWith(
              color: colorScheme.gray900,
            ),
          ),
          AppPrimaryButton.icon(
            onPressed: wm.onAddMaterialRow,
            icon: const Icon(Icons.add),
            label: Text(TasksDecisionStrings.resourcesAddMaterial(context)),
          ),
          ListenableBuilder(
            listenable: state,
            builder: (context, _) {
              final rows = state.materialRows;
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rows.length,
                separatorBuilder: (_, _) {
                  return const SizedBox(
                    height: AppSizes.double12,
                  );
                },
                itemBuilder: (context, index) {
                  final row = rows[index];
                  return MaterialItem(
                    key: ValueKey(row.id),
                    state: row,
                    onRemove: () => wm.onRemoveMaterialRowAt(index),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MaterialShortagesBlock extends StatelessWidget {
  const _MaterialShortagesBlock({required this.state, required this.wm});

  final DecisionResourcesFormStateEntity state;

  final DecisionResourcesScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.gray100,
        borderRadius: AppSizes.borderRadius12,
        border: Border.all(color: colorScheme.gray200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.double12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              TasksDecisionStrings.resourcesShortagesSection(context),
              style: AppTextStyle.t16Medium.value.copyWith(
                color: colorScheme.gray900,
              ),
            ),
            const Height(AppSizes.double8),
            ListenableBuilder(
              listenable: state,
              builder: (context, _) {
                final shortages = wm.calculateMaterialShortages(
                  state.buildMaterials(),
                );
                if (shortages.isEmpty) {
                  return Text(
                    TasksDecisionStrings.resourcesShortagesEmpty(context),
                    style: AppTextStyle.t14.value.copyWith(
                      color: colorScheme.gray700,
                    ),
                  );
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: shortages
                      .map(
                        (shortage) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSizes.double8,
                          ),
                          child: Text(
                            TasksDecisionStrings.resourcesShortageLine(
                              context,
                              label: shortage.label,
                              missing: shortage.missingQuantity,
                              required: shortage.requiredQuantity,
                              available: shortage.availableQuantity,
                              taskCount: shortage.taskCount,
                            ),
                            style: AppTextStyle.t14.value.copyWith(
                              color: colorScheme.gray700,
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
