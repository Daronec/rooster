import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/strings/create_tasks_strings.dart';
import 'package:rooster/uikit/fields/widgets/common/app_dropdown.dart';
import 'package:rooster/uikit/layout_helpers/height.dart';
import 'package:rooster/uikit/sizes/app_sizes.dart';
import 'package:rooster/uikit/text/app_text_style.dart';

/// Выбор исполнителя и наблюдателя задачи из команд Appwrite (если доступно).
final class TaskParticipantPicker extends StatelessWidget {
  /// Создаёт виджет.
  const TaskParticipantPicker({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: wm.participantsLoadingListenable,
      builder: (context, loading, _) {
        if (loading) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text(
                CreateTasksStrings.fieldExecutor(context),
                style: AppTextStyle.t16Bold.value,
              ),
              const Height(AppSizes.double8),
              const LinearProgressIndicator(),
            ],
          );
        }
        return ValueListenableBuilder(
          valueListenable: wm.participantsListenable,
          builder: (context, participants, _) {
            if (participants.isEmpty) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                AppDropdown(
                  label: CreateTasksStrings.fieldExecutor(context),
                  emptyMessage: CreateTasksStrings.participantsEmpty(context),
                  placeholder: CreateTasksStrings.executorPlaceholder(context),
                  valueListenable: wm.formState.executorSelectionListenable,
                  options: wm.participantDropdownOptions,
                  onChanged: (value) {
                    if (kDebugMode) {
                      debugPrint(
                        'create_task_executor_dropdown_onChanged $value',
                      );
                    }
                    wm.formState.setExecutorSelectionId(value);
                  },
                ),
                const Height(AppSizes.double16),
                AppDropdown(
                  label: CreateTasksStrings.fieldObserver(context),
                  emptyMessage: CreateTasksStrings.participantsEmpty(context),
                  placeholder: CreateTasksStrings.observerPlaceholder(context),
                  valueListenable: wm.formState.observerSelectionListenable,
                  options: wm.participantDropdownOptions,
                  onChanged: (value) {
                    if (kDebugMode) {
                      debugPrint(
                        'create_task_observer_dropdown_onChanged $value',
                      );
                    }
                    wm.formState.setObserverSelectionId(value);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
