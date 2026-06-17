import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_material_rows_notifier.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/widgets/common/app_dropdown.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/layout_helpers/width.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Блок строк материалов: название, количество, стоимость, добавление и удаление.
final class MaterialRequirementsBlock extends StatelessWidget {
  /// Создаёт блок.
  const MaterialRequirementsBlock({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wm.materialRows,
      builder: (context, _) {
        final rows = wm.materialRows.rows;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    CreateTasksStrings.sectionMaterials(context),
                    style: AppTextStyle.t14Medium.value,
                  ),
                ),
                IconButton(
                  tooltip: CreateTasksStrings.addMaterialRow(context),
                  onPressed: wm.onAddMaterialRow,
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (rows.isNotEmpty)
            ...rows.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: AppSizes.double12),
                child: _MaterialRequirementRowTile(
                  row: row,
                  onRemove: () => wm.onRemoveMaterialRow(row.id),
                  wm: wm,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

final class _MaterialRequirementRowTile extends StatelessWidget {
  const _MaterialRequirementRowTile({
    required this.row,
    required this.onRemove,
    required this.wm,
  });

  final CreateTaskMaterialRowBinding row;
  final VoidCallback onRemove;
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return Container(
      padding: const EdgeInsets.all(AppSizes.double8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppSizes.double12),
        border: Border.all(color: colorScheme.gray600),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ValueListenableBuilder(
            valueListenable: wm.materialStockItemsListenable,
            builder: (context, items, _) {
              final options = items
                  .where((item) => item.id.trim().isNotEmpty)
                  .map(
                    (item) => AppDropdownEntity(
                      id: item.id,
                      label: item.name.trim().isEmpty ? item.id : item.name,
                    ),
                  )
                  .toList(growable: false);
              return AppDropdown(
                label: CreateTasksStrings.fieldMaterialFromStockLabel(context),
                emptyMessage:
                    CreateTasksStrings.fieldMaterialFromStockEmpty(context),
                placeholder:
                    CreateTasksStrings.fieldMaterialFromStockPlaceholder(context),
                valueListenable: row.stockItemIdListenable,
                options: options,
                onChanged: (selectedId) => wm.onSelectMaterialStockItem(
                  rowId: row.id,
                  stockItemId: selectedId,
                ),
                allowEmptyOptionsDropdown: true,
              );
            },
          ),
          const Height(AppSizes.double8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  key: ValueKey<String>('${row.id}_name'),
                  controller: row.nameController,
                  decoration: InputDecoration(
                    labelText: CreateTasksStrings.fieldMaterialName(context),
                    hintText: CreateTasksStrings.fieldMaterialNameHint(context),
                  ),
                  textCapitalization: TextCapitalization.sentences,
                ),
              ),
              IconButton(
                tooltip: CreateTasksStrings.removeMaterialRow(context),
                onPressed: onRemove,
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          const Height(AppSizes.double8),
          Row(
            children: <Widget>[
              Expanded(
                child: AppTextField(
                  key: ValueKey<String>('${row.id}_qty'),
                  controller: row.quantityController,
                  decoration: InputDecoration(
                    labelText: CreateTasksStrings.fieldMaterialQuantity(
                      context,
                    ),
                    hintText: CreateTasksStrings.fieldMaterialQuantityHint(
                      context,
                    ),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
              const Width(AppSizes.double12),
              Expanded(
                child: AppTextField(
                  key: ValueKey<String>('${row.id}_cost'),
                  controller: row.costController,
                  decoration: InputDecoration(
                    labelText: CreateTasksStrings.fieldMaterialCost(context),
                    hintText: CreateTasksStrings.fieldMaterialCostHint(context),
                  ),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
