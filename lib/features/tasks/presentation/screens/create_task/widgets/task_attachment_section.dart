import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/features/tasks/presentation/widgets/task_attachment_preview.dart';
import 'package:rooster/uikit/buttons/app_primary_button.dart';
import 'package:rooster/uikit/colors/app_color_scheme.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Блок вложений изображений к задаче: превью сеткой 3 в ряд, добавление и удаление.
final class TaskAttachmentSection extends StatelessWidget {
  /// Создаёт блок.
  const TaskAttachmentSection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    final colorScheme = AppColorScheme.of(context);
    return ListenableBuilder(
      listenable: wm.formState,
      builder: (context, _) {
        final attachments = wm.formState.imageAttachments;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: Text(
                    CreateTasksStrings.sectionAttachment(context),
                    style: AppTextStyle.t14Medium.value,
                  ),
                ),
                AppPrimaryButton(
                  onPressed: wm.onPickImages,
                  child: const Icon(Icons.photo_outlined),
                ),
              ],
            ),
            const Height(AppSizes.double8),
            if (attachments.isEmpty)
              taskAttachmentPreview(
                null,
                size: 72,
              )
            else
              LayoutBuilder(
                builder: (context, constraints) {
                  const spacing = AppSizes.double8;
                  final tileSize = (constraints.maxWidth - spacing * 2) / 3;
                  return Wrap(
                    spacing: spacing,
                    runSpacing: spacing,
                    children: [
                      for (var index = 0; index < attachments.length; index++)
                        SizedBox(
                          width: tileSize,
                          height: tileSize,
                          child: RepaintBoundary(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: taskAttachmentPreview(
                                    attachments[index].localPath,
                                    size: tileSize,
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  child: InkWell(
                                    onTap: () => wm.onRemoveImageAt(index),
                                    child: CircleAvatar(
                                      radius: 10,
                                      backgroundColor:
                                          colorScheme.primaryNormal,
                                      child: const Icon(
                                        Icons.close,
                                        size: AppSizes.double16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
          ],
        );
      },
    );
  }
}
