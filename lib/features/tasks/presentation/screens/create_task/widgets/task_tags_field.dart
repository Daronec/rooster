import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:textfield_tags/textfield_tags.dart';

/// Поле ввода тегов задачи.
final class TaskTagsField extends StatelessWidget {
  /// Создаёт поле.
  const TaskTagsField({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return TextFieldTags<String>(
      textfieldTagsController: wm.tagsFieldController,
      initialTags: wm.initialTagsForField,
      textSeparators: const <String>[' ', ','],
      inputFieldBuilder: (context, values) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            AppTextField(
              focusNode: values.focusNode,
              controller: values.textEditingController,
              onChanged: (value) {
                wm.onPendingTagsInputChanged(value);
                values.onTagChanged(value);
              },
              onFieldSubmitted: (value) {
                wm.onPendingTagsSubmitted();
                values.onTagSubmitted(value);
              },
              decoration: InputDecoration(
                hintText: CreateTasksStrings.fieldTagsHint(context),
                errorText: values.error,
              ),
            ),
            if (values.tags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: values.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          padding: const EdgeInsets.all(AppSizes.double4),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSizes.double16,
                            ),
                            side: BorderSide(
                              color: colorScheme.gray300,
                            ),
                          ),
                          onDeleted: () => values.onTagRemoved(tag),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
          ],
        );
      },
    );
  }
}
