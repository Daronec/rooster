import 'package:flutter/material.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/create_task_wm.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/create_task_form_scaffold.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/mobile/create_task_mobile_failure.dart';
import 'package:rooster/features/tasks/presentation/screens/create_task/widgets/mobile/create_task_mobile_loading.dart';

/// Контент экрана создания/редактирования задачи (mobile): форма после bootstrap.
class CreateTaskMobileContent extends StatelessWidget {
  /// Создаёт контент.
  const CreateTaskMobileContent({required this.wm, super.key});

  /// Widget model экрана.
  final CreateTaskScreenWidgetModel wm;

  @override
  Widget build(BuildContext context) {
    return CreateTaskFormScaffold(
      wm: wm,
      listsLoadingBuilder:
          (context, _) => const CreateTaskMobileListsLoadingPanel(),
      listsFailureBuilder: (context, exception, _) {
        return CreateTaskMobileListsFailurePanel(
          onRetry: wm.onRetryLoadLists,
        );
      },
    );
  }
}
