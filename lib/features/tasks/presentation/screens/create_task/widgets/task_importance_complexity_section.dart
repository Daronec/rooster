import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Выбор важности и сложности задачи (1–5) через слайдеры.
final class TaskImportanceComplexitySection extends StatelessWidget {
  /// Создаёт секцию.
  const TaskImportanceComplexitySection({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: wm.formState,
      builder: (context, _) {
        final importance = wm.formState.importance;
        final complexity = wm.formState.complexity;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${CreateTasksStrings.fieldImportance(context)}: $importance',
            ),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              padding: EdgeInsets.zero,
              value: importance.toDouble(),
              onChanged: (value) => wm.formState.setImportance(value.round()),
            ),
            const Height(AppSizes.double16),
            Text(
              '${CreateTasksStrings.fieldComplexity(context)}: $complexity',
            ),
            Slider(
              min: 1,
              max: 5,
              divisions: 4,
              padding: EdgeInsets.zero,
              value: complexity.toDouble(),
              onChanged: (value) => wm.formState.setComplexity(value.round()),
            ),
          ],
        );
      },
    );
  }
}
