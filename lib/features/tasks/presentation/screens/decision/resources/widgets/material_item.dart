import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/decision/resources/entities/decision_resources_form_state_entity.dart';
import 'package:rooster/features/tasks/presentation/strings/tasks_decision_strings.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

///
class MaterialItem extends StatelessWidget {
  ///
  const MaterialItem({
    required this.state,
    required this.onRemove,
    super.key,

  });

  /// Состояние экрана
  final DecisionResourcesMaterialRowEntity state;

  /// Удаление материала
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.double10),
      decoration: BoxDecoration(
        borderRadius: AppSizes.borderRadius16,
        border: Border.all(
          color: colorScheme.gray600,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          AppTextField(
            controller: state.nameController,
            decoration: InputDecoration(
              labelText: TasksDecisionStrings.resourcesMaterialName(context),
            ),
          ),
          const Height(AppSizes.double8),
          AppTextField(
            controller: state.qtyController,
            decoration: InputDecoration(
              labelText: TasksDecisionStrings.resourcesMaterialQty(context),
            ),
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
          ),
          AppPrimaryButton(
            onPressed: onRemove,
            child: Text(TasksDecisionStrings.resourcesRemoveMaterial(context)),
          ),
        ],
      ),
    );
  }
}
