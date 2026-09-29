import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';

/// Stub widget для выбора участника задачи.
///
/// В текущей реализации участники выбираются из команд cloud.ru.
class TaskParticipantPicker extends StatelessWidget {
  /// Создаёт виджет.
  const TaskParticipantPicker({required this.wm, super.key});

  /// Widget model создания задачи.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: wm.participantsLoadingListenable,
      builder: (context, loading, child) {
        if (loading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppSizes.double16),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return child!;
      },
    );
  }
}
