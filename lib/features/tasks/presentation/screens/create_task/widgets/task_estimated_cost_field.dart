import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/fields/widgets/common/app_text_field.dart';

/// Поле ввода оценочной стоимости выполнения задачи.
final class TaskEstimatedCostField extends StatelessWidget {
  /// Создаёт поле.
  const TaskEstimatedCostField({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return AppTextField(
      controller: wm.estimatedCostController,
      decoration: InputDecoration(
        hintText: CreateTasksStrings.fieldEstimatedCostHint(context),
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
    );
  }
}
