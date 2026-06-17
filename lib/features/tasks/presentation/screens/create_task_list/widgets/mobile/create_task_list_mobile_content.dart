import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task_list/create_task_list_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_task_list_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/scaffold/app_scaffold.dart';
import 'package:rooster/uikit/scaffold/default_app_bar.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_scheme.dart';

/// Форма создания списка задач (mobile).
class CreateTaskListMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const CreateTaskListMobileContent({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskListScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    final textScheme = AppTextScheme.of(context);
    return AppScaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: colorScheme.white,
      appBar: DefaultAppBar(
        title: Text(
          wm.isEditingList
              ? CreateTaskListStrings.editScreenTitle(context)
              : CreateTaskListStrings.screenTitle(context),
        ),
        onBackButtonTap: wm.onCancel,
      ),
      body: Padding(
        padding: AppSizes.edgeInsetsAll16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text(
              CreateTaskListStrings.fieldName(context),
              style: textScheme.body.t14Medium,
            ),
            const Height(AppSizes.double8),
            AppTextField(
              controller: wm.nameController,
              decoration: InputDecoration(
                hintText: CreateTaskListStrings.fieldNameHint(context),
              ),
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) {
                wm.onSave();
              },
            ),
            const Height(AppSizes.double16),
            Text(
              CreateTaskListStrings.colorLabel(context),
              style: textScheme.body.t14Medium,
            ),
            const Height(AppSizes.double8),
            ValueListenableBuilder<int>(
              valueListenable: wm.selectedColorArgb,
              builder: (context, selectedArgb, _) {
                return Wrap(
                  spacing: AppSizes.double12,
                  runSpacing: AppSizes.double12,
                  children: <Widget>[
                    for (final int argb in wm.colorPresetArgbValues)
                      _ColorPresetCircle(
                        argb: argb,
                        isSelected: argb == selectedArgb,
                        onTap: () => wm.selectColorPreset(argb),
                      ),
                  ],
                );
              },
            ),
            const Spacer(),
            FilledButton(
              onPressed: wm.onSave,
              child: Text(
                wm.isEditingList
                    ? CreateTaskListStrings.submitEdit(context)
                    : CreateTaskListStrings.save(context),
              ),
            ),
            const Height(AppSizes.double8),
            TextButton(
              onPressed: wm.onCancel,
              child: Text(CreateTaskListStrings.cancel(context)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ColorPresetCircle extends StatelessWidget {
  const _ColorPresetCircle({
    required this.argb,
    required this.isSelected,
    required this.onTap,
  });

  final int argb;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Container(
          width: AppSizes.double40,
          height: AppSizes.double40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Color(argb),
            border: Border.all(
              color: isSelected ? colorScheme.primaryNormal : colorScheme.gray300,
              width: isSelected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}
